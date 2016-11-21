
obj/user/breakpoint.debug:     file format elf32-i386


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
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 ca 1d 80 00       	push   $0x801dca
  800103:	6a 23                	push   $0x23
  800105:	68 e7 1d 80 00       	push   $0x801de7
  80010a:	e8 4a 0f 00 00       	call   801059 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 ca 1d 80 00       	push   $0x801dca
  800184:	6a 23                	push   $0x23
  800186:	68 e7 1d 80 00       	push   $0x801de7
  80018b:	e8 c9 0e 00 00       	call   801059 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 ca 1d 80 00       	push   $0x801dca
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 e7 1d 80 00       	push   $0x801de7
  8001cd:	e8 87 0e 00 00       	call   801059 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 ca 1d 80 00       	push   $0x801dca
  800208:	6a 23                	push   $0x23
  80020a:	68 e7 1d 80 00       	push   $0x801de7
  80020f:	e8 45 0e 00 00       	call   801059 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 ca 1d 80 00       	push   $0x801dca
  80024a:	6a 23                	push   $0x23
  80024c:	68 e7 1d 80 00       	push   $0x801de7
  800251:	e8 03 0e 00 00       	call   801059 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 ca 1d 80 00       	push   $0x801dca
  80028c:	6a 23                	push   $0x23
  80028e:	68 e7 1d 80 00       	push   $0x801de7
  800293:	e8 c1 0d 00 00       	call   801059 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 ca 1d 80 00       	push   $0x801dca
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 e7 1d 80 00       	push   $0x801de7
  8002d5:	e8 7f 0d 00 00       	call   801059 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 ca 1d 80 00       	push   $0x801dca
  800332:	6a 23                	push   $0x23
  800334:	68 e7 1d 80 00       	push   $0x801de7
  800339:	e8 1b 0d 00 00       	call   801059 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 f8 1d 80 00       	push   $0x801df8
  80044d:	e8 e0 0c 00 00       	call   801132 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 39 1e 80 00       	push   $0x801e39
  800677:	e8 b6 0a 00 00       	call   801132 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 55 1e 80 00       	push   $0x801e55
  80074c:	e8 e1 09 00 00       	call   801132 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 18 1e 80 00       	push   $0x801e18
  800801:	e8 2c 09 00 00       	call   801132 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 0c 02 00 00       	call   800ad6 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 aa 11 00 00       	call   801abb <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 3b 11 00 00       	call   801a67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 c5 10 00 00       	call   8019fe <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 f5 0c 00 00       	call   8016b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f5:	89 15 00 50 80 00    	mov    %edx,0x805000
  8009fb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a00:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a05:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a08:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a0e:	53                   	push   %ebx
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	68 08 50 80 00       	push   $0x805008
  800a17:	e8 2d 0e 00 00       	call   801849 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	b8 04 00 00 00       	mov    $0x4,%eax
  800a26:	e8 ca fe ff ff       	call   8008f5 <fsipc>
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 1d                	js     800a4f <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	76 19                	jbe    800a4f <devfile_write+0x6a>
  800a36:	68 84 1e 80 00       	push   $0x801e84
  800a3b:	68 90 1e 80 00       	push   $0x801e90
  800a40:	68 a5 00 00 00       	push   $0xa5
  800a45:	68 a5 1e 80 00       	push   $0x801ea5
  800a4a:	e8 0a 06 00 00       	call   801059 <_panic>
	return r;
}
  800a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a62:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a67:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 03 00 00 00       	mov    $0x3,%eax
  800a77:	e8 79 fe ff ff       	call   8008f5 <fsipc>
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	85 c0                	test   %eax,%eax
  800a80:	78 4b                	js     800acd <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a82:	39 c6                	cmp    %eax,%esi
  800a84:	73 16                	jae    800a9c <devfile_read+0x48>
  800a86:	68 b0 1e 80 00       	push   $0x801eb0
  800a8b:	68 90 1e 80 00       	push   $0x801e90
  800a90:	6a 7c                	push   $0x7c
  800a92:	68 a5 1e 80 00       	push   $0x801ea5
  800a97:	e8 bd 05 00 00       	call   801059 <_panic>
	assert(r <= PGSIZE);
  800a9c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa1:	7e 16                	jle    800ab9 <devfile_read+0x65>
  800aa3:	68 b7 1e 80 00       	push   $0x801eb7
  800aa8:	68 90 1e 80 00       	push   $0x801e90
  800aad:	6a 7d                	push   $0x7d
  800aaf:	68 a5 1e 80 00       	push   $0x801ea5
  800ab4:	e8 a0 05 00 00       	call   801059 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab9:	83 ec 04             	sub    $0x4,%esp
  800abc:	50                   	push   %eax
  800abd:	68 00 50 80 00       	push   $0x805000
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	e8 7f 0d 00 00       	call   801849 <memmove>
	return r;
  800aca:	83 c4 10             	add    $0x10,%esp
}
  800acd:	89 d8                	mov    %ebx,%eax
  800acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 20             	sub    $0x20,%esp
  800add:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae0:	53                   	push   %ebx
  800ae1:	e8 98 0b 00 00       	call   80167e <strlen>
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aee:	7f 67                	jg     800b57 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af6:	50                   	push   %eax
  800af7:	e8 71 f8 ff ff       	call   80036d <fd_alloc>
  800afc:	83 c4 10             	add    $0x10,%esp
		return r;
  800aff:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	78 57                	js     800b5c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	53                   	push   %ebx
  800b09:	68 00 50 80 00       	push   $0x805000
  800b0e:	e8 a4 0b 00 00       	call   8016b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b23:	e8 cd fd ff ff       	call   8008f5 <fsipc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	79 14                	jns    800b45 <open+0x6f>
		fd_close(fd, 0);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	6a 00                	push   $0x0
  800b36:	ff 75 f4             	pushl  -0xc(%ebp)
  800b39:	e8 27 f9 ff ff       	call   800465 <fd_close>
		return r;
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	89 da                	mov    %ebx,%edx
  800b43:	eb 17                	jmp    800b5c <open+0x86>
	}

	return fd2num(fd);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4b:	e8 f6 f7 ff ff       	call   800346 <fd2num>
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	eb 05                	jmp    800b5c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b57:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5c:	89 d0                	mov    %edx,%eax
  800b5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b73:	e8 7d fd ff ff       	call   8008f5 <fsipc>
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 c9 f7 ff ff       	call   800356 <fd2data>
  800b8d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8f:	83 c4 08             	add    $0x8,%esp
  800b92:	68 c3 1e 80 00       	push   $0x801ec3
  800b97:	53                   	push   %ebx
  800b98:	e8 1a 0b 00 00       	call   8016b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9d:	8b 46 04             	mov    0x4(%esi),%eax
  800ba0:	2b 06                	sub    (%esi),%eax
  800ba2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800baf:	00 00 00 
	stat->st_dev = &devpipe;
  800bb2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb9:	30 80 00 
	return 0;
}
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd2:	53                   	push   %ebx
  800bd3:	6a 00                	push   $0x0
  800bd5:	e8 00 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	e8 74 f7 ff ff       	call   800356 <fd2data>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 00                	push   $0x0
  800be8:	e8 ed f5 ff ff       	call   8001da <sys_page_unmap>
}
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bfe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c00:	a1 04 40 80 00       	mov    0x804004,%eax
  800c05:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0e:	e8 e1 0e 00 00       	call   801af4 <pageref>
  800c13:	89 c3                	mov    %eax,%ebx
  800c15:	89 3c 24             	mov    %edi,(%esp)
  800c18:	e8 d7 0e 00 00       	call   801af4 <pageref>
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	39 c3                	cmp    %eax,%ebx
  800c22:	0f 94 c1             	sete   %cl
  800c25:	0f b6 c9             	movzbl %cl,%ecx
  800c28:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c34:	39 ce                	cmp    %ecx,%esi
  800c36:	74 1b                	je     800c53 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c38:	39 c3                	cmp    %eax,%ebx
  800c3a:	75 c4                	jne    800c00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3c:	8b 42 58             	mov    0x58(%edx),%eax
  800c3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c42:	50                   	push   %eax
  800c43:	56                   	push   %esi
  800c44:	68 ca 1e 80 00       	push   $0x801eca
  800c49:	e8 e4 04 00 00       	call   801132 <cprintf>
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	eb ad                	jmp    800c00 <_pipeisclosed+0xe>
	}
}
  800c53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 28             	sub    $0x28,%esp
  800c67:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6a:	56                   	push   %esi
  800c6b:	e8 e6 f6 ff ff       	call   800356 <fd2data>
  800c70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7a:	eb 4b                	jmp    800cc7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7c:	89 da                	mov    %ebx,%edx
  800c7e:	89 f0                	mov    %esi,%eax
  800c80:	e8 6d ff ff ff       	call   800bf2 <_pipeisclosed>
  800c85:	85 c0                	test   %eax,%eax
  800c87:	75 48                	jne    800cd1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c89:	e8 a8 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c91:	8b 0b                	mov    (%ebx),%ecx
  800c93:	8d 51 20             	lea    0x20(%ecx),%edx
  800c96:	39 d0                	cmp    %edx,%eax
  800c98:	73 e2                	jae    800c7c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca4:	89 c2                	mov    %eax,%edx
  800ca6:	c1 fa 1f             	sar    $0x1f,%edx
  800ca9:	89 d1                	mov    %edx,%ecx
  800cab:	c1 e9 1b             	shr    $0x1b,%ecx
  800cae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb1:	83 e2 1f             	and    $0x1f,%edx
  800cb4:	29 ca                	sub    %ecx,%edx
  800cb6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbe:	83 c0 01             	add    $0x1,%eax
  800cc1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc4:	83 c7 01             	add    $0x1,%edi
  800cc7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cca:	75 c2                	jne    800c8e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccf:	eb 05                	jmp    800cd6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 18             	sub    $0x18,%esp
  800ce7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cea:	57                   	push   %edi
  800ceb:	e8 66 f6 ff ff       	call   800356 <fd2data>
  800cf0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf2:	83 c4 10             	add    $0x10,%esp
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	eb 3d                	jmp    800d39 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	74 04                	je     800d04 <devpipe_read+0x26>
				return i;
  800d00:	89 d8                	mov    %ebx,%eax
  800d02:	eb 44                	jmp    800d48 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	89 f8                	mov    %edi,%eax
  800d08:	e8 e5 fe ff ff       	call   800bf2 <_pipeisclosed>
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	75 32                	jne    800d43 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d11:	e8 20 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d16:	8b 06                	mov    (%esi),%eax
  800d18:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1b:	74 df                	je     800cfc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1d:	99                   	cltd   
  800d1e:	c1 ea 1b             	shr    $0x1b,%edx
  800d21:	01 d0                	add    %edx,%eax
  800d23:	83 e0 1f             	and    $0x1f,%eax
  800d26:	29 d0                	sub    %edx,%eax
  800d28:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d33:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d36:	83 c3 01             	add    $0x1,%ebx
  800d39:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3c:	75 d8                	jne    800d16 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d41:	eb 05                	jmp    800d48 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5b:	50                   	push   %eax
  800d5c:	e8 0c f6 ff ff       	call   80036d <fd_alloc>
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	89 c2                	mov    %eax,%edx
  800d66:	85 c0                	test   %eax,%eax
  800d68:	0f 88 2c 01 00 00    	js     800e9a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	68 07 04 00 00       	push   $0x407
  800d76:	ff 75 f4             	pushl  -0xc(%ebp)
  800d79:	6a 00                	push   $0x0
  800d7b:	e8 d5 f3 ff ff       	call   800155 <sys_page_alloc>
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	85 c0                	test   %eax,%eax
  800d87:	0f 88 0d 01 00 00    	js     800e9a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d93:	50                   	push   %eax
  800d94:	e8 d4 f5 ff ff       	call   80036d <fd_alloc>
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	0f 88 e2 00 00 00    	js     800e88 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	68 07 04 00 00       	push   $0x407
  800dae:	ff 75 f0             	pushl  -0x10(%ebp)
  800db1:	6a 00                	push   $0x0
  800db3:	e8 9d f3 ff ff       	call   800155 <sys_page_alloc>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	0f 88 c3 00 00 00    	js     800e88 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcb:	e8 86 f5 ff ff       	call   800356 <fd2data>
  800dd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd2:	83 c4 0c             	add    $0xc,%esp
  800dd5:	68 07 04 00 00       	push   $0x407
  800dda:	50                   	push   %eax
  800ddb:	6a 00                	push   $0x0
  800ddd:	e8 73 f3 ff ff       	call   800155 <sys_page_alloc>
  800de2:	89 c3                	mov    %eax,%ebx
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	0f 88 89 00 00 00    	js     800e78 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	ff 75 f0             	pushl  -0x10(%ebp)
  800df5:	e8 5c f5 ff ff       	call   800356 <fd2data>
  800dfa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e01:	50                   	push   %eax
  800e02:	6a 00                	push   $0x0
  800e04:	56                   	push   %esi
  800e05:	6a 00                	push   $0x0
  800e07:	e8 8c f3 ff ff       	call   800198 <sys_page_map>
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	83 c4 20             	add    $0x20,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 55                	js     800e6a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	ff 75 f4             	pushl  -0xc(%ebp)
  800e45:	e8 fc f4 ff ff       	call   800346 <fd2num>
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4f:	83 c4 04             	add    $0x4,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	e8 ec f4 ff ff       	call   800346 <fd2num>
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	ba 00 00 00 00       	mov    $0x0,%edx
  800e68:	eb 30                	jmp    800e9a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	56                   	push   %esi
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 65 f3 ff ff       	call   8001da <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 55 f3 ff ff       	call   8001da <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 45 f3 ff ff       	call   8001da <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eac:	50                   	push   %eax
  800ead:	ff 75 08             	pushl  0x8(%ebp)
  800eb0:	e8 07 f5 ff ff       	call   8003bc <fd_lookup>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 18                	js     800ed4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec2:	e8 8f f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ec7:	89 c2                	mov    %eax,%edx
  800ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecc:	e8 21 fd ff ff       	call   800bf2 <_pipeisclosed>
  800ed1:	83 c4 10             	add    $0x10,%esp
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee6:	68 e2 1e 80 00       	push   $0x801ee2
  800eeb:	ff 75 0c             	pushl  0xc(%ebp)
  800eee:	e8 c4 07 00 00       	call   8016b7 <strcpy>
	return 0;
}
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f11:	eb 2d                	jmp    800f40 <devcons_write+0x46>
		m = n - tot;
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f16:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f18:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f20:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	53                   	push   %ebx
  800f27:	03 45 0c             	add    0xc(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	57                   	push   %edi
  800f2c:	e8 18 09 00 00       	call   801849 <memmove>
		sys_cputs(buf, m);
  800f31:	83 c4 08             	add    $0x8,%esp
  800f34:	53                   	push   %ebx
  800f35:	57                   	push   %edi
  800f36:	e8 5e f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3b:	01 de                	add    %ebx,%esi
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f45:	72 cc                	jb     800f13 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5e:	74 2a                	je     800f8a <devcons_read+0x3b>
  800f60:	eb 05                	jmp    800f67 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f62:	e8 cf f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f67:	e8 4b f1 ff ff       	call   8000b7 <sys_cgetc>
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	74 f2                	je     800f62 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 16                	js     800f8a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f74:	83 f8 04             	cmp    $0x4,%eax
  800f77:	74 0c                	je     800f85 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7c:	88 02                	mov    %al,(%edx)
	return 1;
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	eb 05                	jmp    800f8a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f92:	8b 45 08             	mov    0x8(%ebp),%eax
  800f95:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f98:	6a 01                	push   $0x1
  800f9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	e8 f6 f0 ff ff       	call   800099 <sys_cputs>
}
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <getchar>:

int
getchar(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fae:	6a 01                	push   $0x1
  800fb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 67 f6 ff ff       	call   800622 <read>
	if (r < 0)
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 0f                	js     800fd1 <getchar+0x29>
		return r;
	if (r < 1)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	7e 06                	jle    800fcc <getchar+0x24>
		return -E_EOF;
	return c;
  800fc6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fca:	eb 05                	jmp    800fd1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 d7 f3 ff ff       	call   8003bc <fd_lookup>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 11                	js     800ffd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff5:	39 10                	cmp    %edx,(%eax)
  800ff7:	0f 94 c0             	sete   %al
  800ffa:	0f b6 c0             	movzbl %al,%eax
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <opencons>:

int
opencons(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	e8 5f f3 ff ff       	call   80036d <fd_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
		return r;
  801011:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	78 3e                	js     801055 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801017:	83 ec 04             	sub    $0x4,%esp
  80101a:	68 07 04 00 00       	push   $0x407
  80101f:	ff 75 f4             	pushl  -0xc(%ebp)
  801022:	6a 00                	push   $0x0
  801024:	e8 2c f1 ff ff       	call   800155 <sys_page_alloc>
  801029:	83 c4 10             	add    $0x10,%esp
		return r;
  80102c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 23                	js     801055 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801032:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801040:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	50                   	push   %eax
  80104b:	e8 f6 f2 ff ff       	call   800346 <fd2num>
  801050:	89 c2                	mov    %eax,%edx
  801052:	83 c4 10             	add    $0x10,%esp
}
  801055:	89 d0                	mov    %edx,%eax
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801061:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801067:	e8 ab f0 ff ff       	call   800117 <sys_getenvid>
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	ff 75 0c             	pushl  0xc(%ebp)
  801072:	ff 75 08             	pushl  0x8(%ebp)
  801075:	56                   	push   %esi
  801076:	50                   	push   %eax
  801077:	68 f0 1e 80 00       	push   $0x801ef0
  80107c:	e8 b1 00 00 00       	call   801132 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801081:	83 c4 18             	add    $0x18,%esp
  801084:	53                   	push   %ebx
  801085:	ff 75 10             	pushl  0x10(%ebp)
  801088:	e8 54 00 00 00       	call   8010e1 <vcprintf>
	cprintf("\n");
  80108d:	c7 04 24 db 1e 80 00 	movl   $0x801edb,(%esp)
  801094:	e8 99 00 00 00       	call   801132 <cprintf>
  801099:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109c:	cc                   	int3   
  80109d:	eb fd                	jmp    80109c <_panic+0x43>

0080109f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a9:	8b 13                	mov    (%ebx),%edx
  8010ab:	8d 42 01             	lea    0x1(%edx),%eax
  8010ae:	89 03                	mov    %eax,(%ebx)
  8010b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bc:	75 1a                	jne    8010d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 ff 00 00 00       	push   $0xff
  8010c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c9:	50                   	push   %eax
  8010ca:	e8 ca ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f1:	00 00 00 
	b.cnt = 0;
  8010f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010fe:	ff 75 0c             	pushl  0xc(%ebp)
  801101:	ff 75 08             	pushl  0x8(%ebp)
  801104:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	68 9f 10 80 00       	push   $0x80109f
  801110:	e8 54 01 00 00       	call   801269 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	e8 6f ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80112a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801138:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113b:	50                   	push   %eax
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	e8 9d ff ff ff       	call   8010e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 1c             	sub    $0x1c,%esp
  80114f:	89 c7                	mov    %eax,%edi
  801151:	89 d6                	mov    %edx,%esi
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	8b 55 0c             	mov    0xc(%ebp),%edx
  801159:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80115f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80116d:	39 d3                	cmp    %edx,%ebx
  80116f:	72 05                	jb     801176 <printnum+0x30>
  801171:	39 45 10             	cmp    %eax,0x10(%ebp)
  801174:	77 45                	ja     8011bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	ff 75 18             	pushl  0x18(%ebp)
  80117c:	8b 45 14             	mov    0x14(%ebp),%eax
  80117f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801182:	53                   	push   %ebx
  801183:	ff 75 10             	pushl  0x10(%ebp)
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118c:	ff 75 e0             	pushl  -0x20(%ebp)
  80118f:	ff 75 dc             	pushl  -0x24(%ebp)
  801192:	ff 75 d8             	pushl  -0x28(%ebp)
  801195:	e8 96 09 00 00       	call   801b30 <__udivdi3>
  80119a:	83 c4 18             	add    $0x18,%esp
  80119d:	52                   	push   %edx
  80119e:	50                   	push   %eax
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	89 f8                	mov    %edi,%eax
  8011a3:	e8 9e ff ff ff       	call   801146 <printnum>
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	eb 18                	jmp    8011c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	56                   	push   %esi
  8011b1:	ff 75 18             	pushl  0x18(%ebp)
  8011b4:	ff d7                	call   *%edi
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	eb 03                	jmp    8011be <printnum+0x78>
  8011bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011be:	83 eb 01             	sub    $0x1,%ebx
  8011c1:	85 db                	test   %ebx,%ebx
  8011c3:	7f e8                	jg     8011ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	56                   	push   %esi
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d8:	e8 83 0a 00 00       	call   801c60 <__umoddi3>
  8011dd:	83 c4 14             	add    $0x14,%esp
  8011e0:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  8011e7:	50                   	push   %eax
  8011e8:	ff d7                	call   *%edi
}
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f8:	83 fa 01             	cmp    $0x1,%edx
  8011fb:	7e 0e                	jle    80120b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011fd:	8b 10                	mov    (%eax),%edx
  8011ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  801202:	89 08                	mov    %ecx,(%eax)
  801204:	8b 02                	mov    (%edx),%eax
  801206:	8b 52 04             	mov    0x4(%edx),%edx
  801209:	eb 22                	jmp    80122d <getuint+0x38>
	else if (lflag)
  80120b:	85 d2                	test   %edx,%edx
  80120d:	74 10                	je     80121f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80120f:	8b 10                	mov    (%eax),%edx
  801211:	8d 4a 04             	lea    0x4(%edx),%ecx
  801214:	89 08                	mov    %ecx,(%eax)
  801216:	8b 02                	mov    (%edx),%eax
  801218:	ba 00 00 00 00       	mov    $0x0,%edx
  80121d:	eb 0e                	jmp    80122d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80121f:	8b 10                	mov    (%eax),%edx
  801221:	8d 4a 04             	lea    0x4(%edx),%ecx
  801224:	89 08                	mov    %ecx,(%eax)
  801226:	8b 02                	mov    (%edx),%eax
  801228:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801235:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801239:	8b 10                	mov    (%eax),%edx
  80123b:	3b 50 04             	cmp    0x4(%eax),%edx
  80123e:	73 0a                	jae    80124a <sprintputch+0x1b>
		*b->buf++ = ch;
  801240:	8d 4a 01             	lea    0x1(%edx),%ecx
  801243:	89 08                	mov    %ecx,(%eax)
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
  801248:	88 02                	mov    %al,(%edx)
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801252:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801255:	50                   	push   %eax
  801256:	ff 75 10             	pushl  0x10(%ebp)
  801259:	ff 75 0c             	pushl  0xc(%ebp)
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 05 00 00 00       	call   801269 <vprintfmt>
	va_end(ap);
}
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 2c             	sub    $0x2c,%esp
  801272:	8b 75 08             	mov    0x8(%ebp),%esi
  801275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801278:	8b 7d 10             	mov    0x10(%ebp),%edi
  80127b:	eb 12                	jmp    80128f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80127d:	85 c0                	test   %eax,%eax
  80127f:	0f 84 89 03 00 00    	je     80160e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	53                   	push   %ebx
  801289:	50                   	push   %eax
  80128a:	ff d6                	call   *%esi
  80128c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80128f:	83 c7 01             	add    $0x1,%edi
  801292:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801296:	83 f8 25             	cmp    $0x25,%eax
  801299:	75 e2                	jne    80127d <vprintfmt+0x14>
  80129b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80129f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b9:	eb 07                	jmp    8012c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8d 47 01             	lea    0x1(%edi),%eax
  8012c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c8:	0f b6 07             	movzbl (%edi),%eax
  8012cb:	0f b6 c8             	movzbl %al,%ecx
  8012ce:	83 e8 23             	sub    $0x23,%eax
  8012d1:	3c 55                	cmp    $0x55,%al
  8012d3:	0f 87 1a 03 00 00    	ja     8015f3 <vprintfmt+0x38a>
  8012d9:	0f b6 c0             	movzbl %al,%eax
  8012dc:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012ea:	eb d6                	jmp    8012c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801301:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801304:	83 fa 09             	cmp    $0x9,%edx
  801307:	77 39                	ja     801342 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801309:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80130c:	eb e9                	jmp    8012f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130e:	8b 45 14             	mov    0x14(%ebp),%eax
  801311:	8d 48 04             	lea    0x4(%eax),%ecx
  801314:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801317:	8b 00                	mov    (%eax),%eax
  801319:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80131f:	eb 27                	jmp    801348 <vprintfmt+0xdf>
  801321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801324:	85 c0                	test   %eax,%eax
  801326:	b9 00 00 00 00       	mov    $0x0,%ecx
  80132b:	0f 49 c8             	cmovns %eax,%ecx
  80132e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801334:	eb 8c                	jmp    8012c2 <vprintfmt+0x59>
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801339:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801340:	eb 80                	jmp    8012c2 <vprintfmt+0x59>
  801342:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801345:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134c:	0f 89 70 ff ff ff    	jns    8012c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801352:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801355:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801358:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80135f:	e9 5e ff ff ff       	jmp    8012c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801364:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80136a:	e9 53 ff ff ff       	jmp    8012c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8d 50 04             	lea    0x4(%eax),%edx
  801375:	89 55 14             	mov    %edx,0x14(%ebp)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	53                   	push   %ebx
  80137c:	ff 30                	pushl  (%eax)
  80137e:	ff d6                	call   *%esi
			break;
  801380:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801386:	e9 04 ff ff ff       	jmp    80128f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138b:	8b 45 14             	mov    0x14(%ebp),%eax
  80138e:	8d 50 04             	lea    0x4(%eax),%edx
  801391:	89 55 14             	mov    %edx,0x14(%ebp)
  801394:	8b 00                	mov    (%eax),%eax
  801396:	99                   	cltd   
  801397:	31 d0                	xor    %edx,%eax
  801399:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80139b:	83 f8 0f             	cmp    $0xf,%eax
  80139e:	7f 0b                	jg     8013ab <vprintfmt+0x142>
  8013a0:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013a7:	85 d2                	test   %edx,%edx
  8013a9:	75 18                	jne    8013c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013ab:	50                   	push   %eax
  8013ac:	68 2b 1f 80 00       	push   $0x801f2b
  8013b1:	53                   	push   %ebx
  8013b2:	56                   	push   %esi
  8013b3:	e8 94 fe ff ff       	call   80124c <printfmt>
  8013b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013be:	e9 cc fe ff ff       	jmp    80128f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c3:	52                   	push   %edx
  8013c4:	68 a2 1e 80 00       	push   $0x801ea2
  8013c9:	53                   	push   %ebx
  8013ca:	56                   	push   %esi
  8013cb:	e8 7c fe ff ff       	call   80124c <printfmt>
  8013d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d6:	e9 b4 fe ff ff       	jmp    80128f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	8d 50 04             	lea    0x4(%eax),%edx
  8013e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e6:	85 ff                	test   %edi,%edi
  8013e8:	b8 24 1f 80 00       	mov    $0x801f24,%eax
  8013ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f4:	0f 8e 94 00 00 00    	jle    80148e <vprintfmt+0x225>
  8013fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013fe:	0f 84 98 00 00 00    	je     80149c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	ff 75 d0             	pushl  -0x30(%ebp)
  80140a:	57                   	push   %edi
  80140b:	e8 86 02 00 00       	call   801696 <strnlen>
  801410:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801413:	29 c1                	sub    %eax,%ecx
  801415:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801418:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80141b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80141f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801422:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801425:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801427:	eb 0f                	jmp    801438 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	53                   	push   %ebx
  80142d:	ff 75 e0             	pushl  -0x20(%ebp)
  801430:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801432:	83 ef 01             	sub    $0x1,%edi
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 ff                	test   %edi,%edi
  80143a:	7f ed                	jg     801429 <vprintfmt+0x1c0>
  80143c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80143f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801442:	85 c9                	test   %ecx,%ecx
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
  801449:	0f 49 c1             	cmovns %ecx,%eax
  80144c:	29 c1                	sub    %eax,%ecx
  80144e:	89 75 08             	mov    %esi,0x8(%ebp)
  801451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801457:	89 cb                	mov    %ecx,%ebx
  801459:	eb 4d                	jmp    8014a8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80145b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80145f:	74 1b                	je     80147c <vprintfmt+0x213>
  801461:	0f be c0             	movsbl %al,%eax
  801464:	83 e8 20             	sub    $0x20,%eax
  801467:	83 f8 5e             	cmp    $0x5e,%eax
  80146a:	76 10                	jbe    80147c <vprintfmt+0x213>
					putch('?', putdat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	6a 3f                	push   $0x3f
  801474:	ff 55 08             	call   *0x8(%ebp)
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	eb 0d                	jmp    801489 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	ff 75 0c             	pushl  0xc(%ebp)
  801482:	52                   	push   %edx
  801483:	ff 55 08             	call   *0x8(%ebp)
  801486:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801489:	83 eb 01             	sub    $0x1,%ebx
  80148c:	eb 1a                	jmp    8014a8 <vprintfmt+0x23f>
  80148e:	89 75 08             	mov    %esi,0x8(%ebp)
  801491:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801494:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801497:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149a:	eb 0c                	jmp    8014a8 <vprintfmt+0x23f>
  80149c:	89 75 08             	mov    %esi,0x8(%ebp)
  80149f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a8:	83 c7 01             	add    $0x1,%edi
  8014ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014af:	0f be d0             	movsbl %al,%edx
  8014b2:	85 d2                	test   %edx,%edx
  8014b4:	74 23                	je     8014d9 <vprintfmt+0x270>
  8014b6:	85 f6                	test   %esi,%esi
  8014b8:	78 a1                	js     80145b <vprintfmt+0x1f2>
  8014ba:	83 ee 01             	sub    $0x1,%esi
  8014bd:	79 9c                	jns    80145b <vprintfmt+0x1f2>
  8014bf:	89 df                	mov    %ebx,%edi
  8014c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c7:	eb 18                	jmp    8014e1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	6a 20                	push   $0x20
  8014cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d1:	83 ef 01             	sub    $0x1,%edi
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	eb 08                	jmp    8014e1 <vprintfmt+0x278>
  8014d9:	89 df                	mov    %ebx,%edi
  8014db:	8b 75 08             	mov    0x8(%ebp),%esi
  8014de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e1:	85 ff                	test   %edi,%edi
  8014e3:	7f e4                	jg     8014c9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e8:	e9 a2 fd ff ff       	jmp    80128f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ed:	83 fa 01             	cmp    $0x1,%edx
  8014f0:	7e 16                	jle    801508 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 50 08             	lea    0x8(%eax),%edx
  8014f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fb:	8b 50 04             	mov    0x4(%eax),%edx
  8014fe:	8b 00                	mov    (%eax),%eax
  801500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801503:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801506:	eb 32                	jmp    80153a <vprintfmt+0x2d1>
	else if (lflag)
  801508:	85 d2                	test   %edx,%edx
  80150a:	74 18                	je     801524 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8d 50 04             	lea    0x4(%eax),%edx
  801512:	89 55 14             	mov    %edx,0x14(%ebp)
  801515:	8b 00                	mov    (%eax),%eax
  801517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151a:	89 c1                	mov    %eax,%ecx
  80151c:	c1 f9 1f             	sar    $0x1f,%ecx
  80151f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801522:	eb 16                	jmp    80153a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801524:	8b 45 14             	mov    0x14(%ebp),%eax
  801527:	8d 50 04             	lea    0x4(%eax),%edx
  80152a:	89 55 14             	mov    %edx,0x14(%ebp)
  80152d:	8b 00                	mov    (%eax),%eax
  80152f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801532:	89 c1                	mov    %eax,%ecx
  801534:	c1 f9 1f             	sar    $0x1f,%ecx
  801537:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801540:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801545:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801549:	79 74                	jns    8015bf <vprintfmt+0x356>
				putch('-', putdat);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	53                   	push   %ebx
  80154f:	6a 2d                	push   $0x2d
  801551:	ff d6                	call   *%esi
				num = -(long long) num;
  801553:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801556:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801559:	f7 d8                	neg    %eax
  80155b:	83 d2 00             	adc    $0x0,%edx
  80155e:	f7 da                	neg    %edx
  801560:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801563:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801568:	eb 55                	jmp    8015bf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156a:	8d 45 14             	lea    0x14(%ebp),%eax
  80156d:	e8 83 fc ff ff       	call   8011f5 <getuint>
			base = 10;
  801572:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801577:	eb 46                	jmp    8015bf <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801579:	8d 45 14             	lea    0x14(%ebp),%eax
  80157c:	e8 74 fc ff ff       	call   8011f5 <getuint>
                        base = 8;
  801581:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801586:	eb 37                	jmp    8015bf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	6a 30                	push   $0x30
  80158e:	ff d6                	call   *%esi
			putch('x', putdat);
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	53                   	push   %ebx
  801594:	6a 78                	push   $0x78
  801596:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8d 50 04             	lea    0x4(%eax),%edx
  80159e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a1:	8b 00                	mov    (%eax),%eax
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b0:	eb 0d                	jmp    8015bf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b5:	e8 3b fc ff ff       	call   8011f5 <getuint>
			base = 16;
  8015ba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c6:	57                   	push   %edi
  8015c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ca:	51                   	push   %ecx
  8015cb:	52                   	push   %edx
  8015cc:	50                   	push   %eax
  8015cd:	89 da                	mov    %ebx,%edx
  8015cf:	89 f0                	mov    %esi,%eax
  8015d1:	e8 70 fb ff ff       	call   801146 <printnum>
			break;
  8015d6:	83 c4 20             	add    $0x20,%esp
  8015d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015dc:	e9 ae fc ff ff       	jmp    80128f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	51                   	push   %ecx
  8015e6:	ff d6                	call   *%esi
			break;
  8015e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ee:	e9 9c fc ff ff       	jmp    80128f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	6a 25                	push   $0x25
  8015f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 03                	jmp    801603 <vprintfmt+0x39a>
  801600:	83 ef 01             	sub    $0x1,%edi
  801603:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801607:	75 f7                	jne    801600 <vprintfmt+0x397>
  801609:	e9 81 fc ff ff       	jmp    80128f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 18             	sub    $0x18,%esp
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801622:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801625:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801629:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801633:	85 c0                	test   %eax,%eax
  801635:	74 26                	je     80165d <vsnprintf+0x47>
  801637:	85 d2                	test   %edx,%edx
  801639:	7e 22                	jle    80165d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163b:	ff 75 14             	pushl  0x14(%ebp)
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	68 2f 12 80 00       	push   $0x80122f
  80164a:	e8 1a fc ff ff       	call   801269 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801652:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb 05                	jmp    801662 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166d:	50                   	push   %eax
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 9a ff ff ff       	call   801616 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
  801689:	eb 03                	jmp    80168e <strlen+0x10>
		n++;
  80168b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801692:	75 f7                	jne    80168b <strlen+0xd>
		n++;
	return n;
}
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	eb 03                	jmp    8016a9 <strnlen+0x13>
		n++;
  8016a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a9:	39 c2                	cmp    %eax,%edx
  8016ab:	74 08                	je     8016b5 <strnlen+0x1f>
  8016ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b1:	75 f3                	jne    8016a6 <strnlen+0x10>
  8016b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	83 c2 01             	add    $0x1,%edx
  8016c6:	83 c1 01             	add    $0x1,%ecx
  8016c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d0:	84 db                	test   %bl,%bl
  8016d2:	75 ef                	jne    8016c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d4:	5b                   	pop    %ebx
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016de:	53                   	push   %ebx
  8016df:	e8 9a ff ff ff       	call   80167e <strlen>
  8016e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	01 d8                	add    %ebx,%eax
  8016ec:	50                   	push   %eax
  8016ed:	e8 c5 ff ff ff       	call   8016b7 <strcpy>
	return dst;
}
  8016f2:	89 d8                	mov    %ebx,%eax
  8016f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	89 f3                	mov    %esi,%ebx
  801706:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801709:	89 f2                	mov    %esi,%edx
  80170b:	eb 0f                	jmp    80171c <strncpy+0x23>
		*dst++ = *src;
  80170d:	83 c2 01             	add    $0x1,%edx
  801710:	0f b6 01             	movzbl (%ecx),%eax
  801713:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801716:	80 39 01             	cmpb   $0x1,(%ecx)
  801719:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171c:	39 da                	cmp    %ebx,%edx
  80171e:	75 ed                	jne    80170d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801720:	89 f0                	mov    %esi,%eax
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
  80172e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801731:	8b 55 10             	mov    0x10(%ebp),%edx
  801734:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801736:	85 d2                	test   %edx,%edx
  801738:	74 21                	je     80175b <strlcpy+0x35>
  80173a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173e:	89 f2                	mov    %esi,%edx
  801740:	eb 09                	jmp    80174b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801742:	83 c2 01             	add    $0x1,%edx
  801745:	83 c1 01             	add    $0x1,%ecx
  801748:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80174b:	39 c2                	cmp    %eax,%edx
  80174d:	74 09                	je     801758 <strlcpy+0x32>
  80174f:	0f b6 19             	movzbl (%ecx),%ebx
  801752:	84 db                	test   %bl,%bl
  801754:	75 ec                	jne    801742 <strlcpy+0x1c>
  801756:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801758:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175b:	29 f0                	sub    %esi,%eax
}
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801767:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176a:	eb 06                	jmp    801772 <strcmp+0x11>
		p++, q++;
  80176c:	83 c1 01             	add    $0x1,%ecx
  80176f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801772:	0f b6 01             	movzbl (%ecx),%eax
  801775:	84 c0                	test   %al,%al
  801777:	74 04                	je     80177d <strcmp+0x1c>
  801779:	3a 02                	cmp    (%edx),%al
  80177b:	74 ef                	je     80176c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177d:	0f b6 c0             	movzbl %al,%eax
  801780:	0f b6 12             	movzbl (%edx),%edx
  801783:	29 d0                	sub    %edx,%eax
}
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	8b 45 08             	mov    0x8(%ebp),%eax
  80178e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801791:	89 c3                	mov    %eax,%ebx
  801793:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801796:	eb 06                	jmp    80179e <strncmp+0x17>
		n--, p++, q++;
  801798:	83 c0 01             	add    $0x1,%eax
  80179b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179e:	39 d8                	cmp    %ebx,%eax
  8017a0:	74 15                	je     8017b7 <strncmp+0x30>
  8017a2:	0f b6 08             	movzbl (%eax),%ecx
  8017a5:	84 c9                	test   %cl,%cl
  8017a7:	74 04                	je     8017ad <strncmp+0x26>
  8017a9:	3a 0a                	cmp    (%edx),%cl
  8017ab:	74 eb                	je     801798 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ad:	0f b6 00             	movzbl (%eax),%eax
  8017b0:	0f b6 12             	movzbl (%edx),%edx
  8017b3:	29 d0                	sub    %edx,%eax
  8017b5:	eb 05                	jmp    8017bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bc:	5b                   	pop    %ebx
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c9:	eb 07                	jmp    8017d2 <strchr+0x13>
		if (*s == c)
  8017cb:	38 ca                	cmp    %cl,%dl
  8017cd:	74 0f                	je     8017de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017cf:	83 c0 01             	add    $0x1,%eax
  8017d2:	0f b6 10             	movzbl (%eax),%edx
  8017d5:	84 d2                	test   %dl,%dl
  8017d7:	75 f2                	jne    8017cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ea:	eb 03                	jmp    8017ef <strfind+0xf>
  8017ec:	83 c0 01             	add    $0x1,%eax
  8017ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f2:	38 ca                	cmp    %cl,%dl
  8017f4:	74 04                	je     8017fa <strfind+0x1a>
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	75 f2                	jne    8017ec <strfind+0xc>
			break;
	return (char *) s;
}
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	57                   	push   %edi
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	8b 7d 08             	mov    0x8(%ebp),%edi
  801805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801808:	85 c9                	test   %ecx,%ecx
  80180a:	74 36                	je     801842 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801812:	75 28                	jne    80183c <memset+0x40>
  801814:	f6 c1 03             	test   $0x3,%cl
  801817:	75 23                	jne    80183c <memset+0x40>
		c &= 0xFF;
  801819:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181d:	89 d3                	mov    %edx,%ebx
  80181f:	c1 e3 08             	shl    $0x8,%ebx
  801822:	89 d6                	mov    %edx,%esi
  801824:	c1 e6 18             	shl    $0x18,%esi
  801827:	89 d0                	mov    %edx,%eax
  801829:	c1 e0 10             	shl    $0x10,%eax
  80182c:	09 f0                	or     %esi,%eax
  80182e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801830:	89 d8                	mov    %ebx,%eax
  801832:	09 d0                	or     %edx,%eax
  801834:	c1 e9 02             	shr    $0x2,%ecx
  801837:	fc                   	cld    
  801838:	f3 ab                	rep stos %eax,%es:(%edi)
  80183a:	eb 06                	jmp    801842 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	fc                   	cld    
  801840:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801842:	89 f8                	mov    %edi,%eax
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5f                   	pop    %edi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	57                   	push   %edi
  80184d:	56                   	push   %esi
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 75 0c             	mov    0xc(%ebp),%esi
  801854:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801857:	39 c6                	cmp    %eax,%esi
  801859:	73 35                	jae    801890 <memmove+0x47>
  80185b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185e:	39 d0                	cmp    %edx,%eax
  801860:	73 2e                	jae    801890 <memmove+0x47>
		s += n;
		d += n;
  801862:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801865:	89 d6                	mov    %edx,%esi
  801867:	09 fe                	or     %edi,%esi
  801869:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186f:	75 13                	jne    801884 <memmove+0x3b>
  801871:	f6 c1 03             	test   $0x3,%cl
  801874:	75 0e                	jne    801884 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801876:	83 ef 04             	sub    $0x4,%edi
  801879:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187c:	c1 e9 02             	shr    $0x2,%ecx
  80187f:	fd                   	std    
  801880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801882:	eb 09                	jmp    80188d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801884:	83 ef 01             	sub    $0x1,%edi
  801887:	8d 72 ff             	lea    -0x1(%edx),%esi
  80188a:	fd                   	std    
  80188b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188d:	fc                   	cld    
  80188e:	eb 1d                	jmp    8018ad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801890:	89 f2                	mov    %esi,%edx
  801892:	09 c2                	or     %eax,%edx
  801894:	f6 c2 03             	test   $0x3,%dl
  801897:	75 0f                	jne    8018a8 <memmove+0x5f>
  801899:	f6 c1 03             	test   $0x3,%cl
  80189c:	75 0a                	jne    8018a8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80189e:	c1 e9 02             	shr    $0x2,%ecx
  8018a1:	89 c7                	mov    %eax,%edi
  8018a3:	fc                   	cld    
  8018a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a6:	eb 05                	jmp    8018ad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a8:	89 c7                	mov    %eax,%edi
  8018aa:	fc                   	cld    
  8018ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ad:	5e                   	pop    %esi
  8018ae:	5f                   	pop    %edi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b4:	ff 75 10             	pushl  0x10(%ebp)
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 87 ff ff ff       	call   801849 <memmove>
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cf:	89 c6                	mov    %eax,%esi
  8018d1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d4:	eb 1a                	jmp    8018f0 <memcmp+0x2c>
		if (*s1 != *s2)
  8018d6:	0f b6 08             	movzbl (%eax),%ecx
  8018d9:	0f b6 1a             	movzbl (%edx),%ebx
  8018dc:	38 d9                	cmp    %bl,%cl
  8018de:	74 0a                	je     8018ea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e0:	0f b6 c1             	movzbl %cl,%eax
  8018e3:	0f b6 db             	movzbl %bl,%ebx
  8018e6:	29 d8                	sub    %ebx,%eax
  8018e8:	eb 0f                	jmp    8018f9 <memcmp+0x35>
		s1++, s2++;
  8018ea:	83 c0 01             	add    $0x1,%eax
  8018ed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f0:	39 f0                	cmp    %esi,%eax
  8018f2:	75 e2                	jne    8018d6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801904:	89 c1                	mov    %eax,%ecx
  801906:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801909:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190d:	eb 0a                	jmp    801919 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190f:	0f b6 10             	movzbl (%eax),%edx
  801912:	39 da                	cmp    %ebx,%edx
  801914:	74 07                	je     80191d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	39 c8                	cmp    %ecx,%eax
  80191b:	72 f2                	jb     80190f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80191d:	5b                   	pop    %ebx
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	57                   	push   %edi
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801929:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192c:	eb 03                	jmp    801931 <strtol+0x11>
		s++;
  80192e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801931:	0f b6 01             	movzbl (%ecx),%eax
  801934:	3c 20                	cmp    $0x20,%al
  801936:	74 f6                	je     80192e <strtol+0xe>
  801938:	3c 09                	cmp    $0x9,%al
  80193a:	74 f2                	je     80192e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193c:	3c 2b                	cmp    $0x2b,%al
  80193e:	75 0a                	jne    80194a <strtol+0x2a>
		s++;
  801940:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801943:	bf 00 00 00 00       	mov    $0x0,%edi
  801948:	eb 11                	jmp    80195b <strtol+0x3b>
  80194a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194f:	3c 2d                	cmp    $0x2d,%al
  801951:	75 08                	jne    80195b <strtol+0x3b>
		s++, neg = 1;
  801953:	83 c1 01             	add    $0x1,%ecx
  801956:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801961:	75 15                	jne    801978 <strtol+0x58>
  801963:	80 39 30             	cmpb   $0x30,(%ecx)
  801966:	75 10                	jne    801978 <strtol+0x58>
  801968:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196c:	75 7c                	jne    8019ea <strtol+0xca>
		s += 2, base = 16;
  80196e:	83 c1 02             	add    $0x2,%ecx
  801971:	bb 10 00 00 00       	mov    $0x10,%ebx
  801976:	eb 16                	jmp    80198e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801978:	85 db                	test   %ebx,%ebx
  80197a:	75 12                	jne    80198e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801981:	80 39 30             	cmpb   $0x30,(%ecx)
  801984:	75 08                	jne    80198e <strtol+0x6e>
		s++, base = 8;
  801986:	83 c1 01             	add    $0x1,%ecx
  801989:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
  801993:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801996:	0f b6 11             	movzbl (%ecx),%edx
  801999:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199c:	89 f3                	mov    %esi,%ebx
  80199e:	80 fb 09             	cmp    $0x9,%bl
  8019a1:	77 08                	ja     8019ab <strtol+0x8b>
			dig = *s - '0';
  8019a3:	0f be d2             	movsbl %dl,%edx
  8019a6:	83 ea 30             	sub    $0x30,%edx
  8019a9:	eb 22                	jmp    8019cd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ab:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ae:	89 f3                	mov    %esi,%ebx
  8019b0:	80 fb 19             	cmp    $0x19,%bl
  8019b3:	77 08                	ja     8019bd <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019b5:	0f be d2             	movsbl %dl,%edx
  8019b8:	83 ea 57             	sub    $0x57,%edx
  8019bb:	eb 10                	jmp    8019cd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019bd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c0:	89 f3                	mov    %esi,%ebx
  8019c2:	80 fb 19             	cmp    $0x19,%bl
  8019c5:	77 16                	ja     8019dd <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019c7:	0f be d2             	movsbl %dl,%edx
  8019ca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019cd:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d0:	7d 0b                	jge    8019dd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d2:	83 c1 01             	add    $0x1,%ecx
  8019d5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019db:	eb b9                	jmp    801996 <strtol+0x76>

	if (endptr)
  8019dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e1:	74 0d                	je     8019f0 <strtol+0xd0>
		*endptr = (char *) s;
  8019e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e6:	89 0e                	mov    %ecx,(%esi)
  8019e8:	eb 06                	jmp    8019f0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ea:	85 db                	test   %ebx,%ebx
  8019ec:	74 98                	je     801986 <strtol+0x66>
  8019ee:	eb 9e                	jmp    80198e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	f7 da                	neg    %edx
  8019f4:	85 ff                	test   %edi,%edi
  8019f6:	0f 45 c2             	cmovne %edx,%eax
}
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5f                   	pop    %edi
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 75 08             	mov    0x8(%ebp),%esi
  801a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a0c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a0e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a13:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	50                   	push   %eax
  801a1a:	e8 e6 e8 ff ff       	call   800305 <sys_ipc_recv>

	if (r < 0) {
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	85 c0                	test   %eax,%eax
  801a24:	79 16                	jns    801a3c <ipc_recv+0x3e>
		if (from_env_store)
  801a26:	85 f6                	test   %esi,%esi
  801a28:	74 06                	je     801a30 <ipc_recv+0x32>
			*from_env_store = 0;
  801a2a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a30:	85 db                	test   %ebx,%ebx
  801a32:	74 2c                	je     801a60 <ipc_recv+0x62>
			*perm_store = 0;
  801a34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3a:	eb 24                	jmp    801a60 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a3c:	85 f6                	test   %esi,%esi
  801a3e:	74 0a                	je     801a4a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a40:	a1 04 40 80 00       	mov    0x804004,%eax
  801a45:	8b 40 74             	mov    0x74(%eax),%eax
  801a48:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a4a:	85 db                	test   %ebx,%ebx
  801a4c:	74 0a                	je     801a58 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a53:	8b 40 78             	mov    0x78(%eax),%eax
  801a56:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a58:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	57                   	push   %edi
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a79:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a7b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a80:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a83:	ff 75 14             	pushl  0x14(%ebp)
  801a86:	53                   	push   %ebx
  801a87:	56                   	push   %esi
  801a88:	57                   	push   %edi
  801a89:	e8 54 e8 ff ff       	call   8002e2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a94:	75 07                	jne    801a9d <ipc_send+0x36>
			sys_yield();
  801a96:	e8 9b e6 ff ff       	call   800136 <sys_yield>
  801a9b:	eb e6                	jmp    801a83 <ipc_send+0x1c>
		} else if (r < 0) {
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 12                	jns    801ab3 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801aa1:	50                   	push   %eax
  801aa2:	68 20 22 80 00       	push   $0x802220
  801aa7:	6a 51                	push   $0x51
  801aa9:	68 2d 22 80 00       	push   $0x80222d
  801aae:	e8 a6 f5 ff ff       	call   801059 <_panic>
		}
	}
}
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ac9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801acf:	8b 52 50             	mov    0x50(%edx),%edx
  801ad2:	39 ca                	cmp    %ecx,%edx
  801ad4:	75 0d                	jne    801ae3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ad9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ade:	8b 40 48             	mov    0x48(%eax),%eax
  801ae1:	eb 0f                	jmp    801af2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae3:	83 c0 01             	add    $0x1,%eax
  801ae6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aeb:	75 d9                	jne    801ac6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afa:	89 d0                	mov    %edx,%eax
  801afc:	c1 e8 16             	shr    $0x16,%eax
  801aff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0b:	f6 c1 01             	test   $0x1,%cl
  801b0e:	74 1d                	je     801b2d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b10:	c1 ea 0c             	shr    $0xc,%edx
  801b13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1a:	f6 c2 01             	test   $0x1,%dl
  801b1d:	74 0e                	je     801b2d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b1f:	c1 ea 0c             	shr    $0xc,%edx
  801b22:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b29:	ef 
  801b2a:	0f b7 c0             	movzwl %ax,%eax
}
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b47:	85 f6                	test   %esi,%esi
  801b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4d:	89 ca                	mov    %ecx,%edx
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	75 3d                	jne    801b90 <__udivdi3+0x60>
  801b53:	39 cf                	cmp    %ecx,%edi
  801b55:	0f 87 c5 00 00 00    	ja     801c20 <__udivdi3+0xf0>
  801b5b:	85 ff                	test   %edi,%edi
  801b5d:	89 fd                	mov    %edi,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f7                	div    %edi
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 c8                	mov    %ecx,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c1                	mov    %eax,%ecx
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	89 cf                	mov    %ecx,%edi
  801b78:	f7 f5                	div    %ebp
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	89 fa                	mov    %edi,%edx
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	90                   	nop
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	77 74                	ja     801c08 <__udivdi3+0xd8>
  801b94:	0f bd fe             	bsr    %esi,%edi
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	0f 84 98 00 00 00    	je     801c38 <__udivdi3+0x108>
  801ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	89 c5                	mov    %eax,%ebp
  801ba9:	29 fb                	sub    %edi,%ebx
  801bab:	d3 e6                	shl    %cl,%esi
  801bad:	89 d9                	mov    %ebx,%ecx
  801baf:	d3 ed                	shr    %cl,%ebp
  801bb1:	89 f9                	mov    %edi,%ecx
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	09 ee                	or     %ebp,%esi
  801bb7:	89 d9                	mov    %ebx,%ecx
  801bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbd:	89 d5                	mov    %edx,%ebp
  801bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bc3:	d3 ed                	shr    %cl,%ebp
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e2                	shl    %cl,%edx
  801bc9:	89 d9                	mov    %ebx,%ecx
  801bcb:	d3 e8                	shr    %cl,%eax
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	89 ea                	mov    %ebp,%edx
  801bd3:	f7 f6                	div    %esi
  801bd5:	89 d5                	mov    %edx,%ebp
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	f7 64 24 0c          	mull   0xc(%esp)
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	72 10                	jb     801bf1 <__udivdi3+0xc1>
  801be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e6                	shl    %cl,%esi
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 07                	jae    801bf4 <__udivdi3+0xc4>
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	75 03                	jne    801bf4 <__udivdi3+0xc4>
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	83 c4 1c             	add    $0x1c,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
  801c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c08:	31 ff                	xor    %edi,%edi
  801c0a:	31 db                	xor    %ebx,%ebx
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
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f7                	div    %edi
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	89 fa                	mov    %edi,%edx
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0c                	jb     801c48 <__udivdi3+0x118>
  801c3c:	31 db                	xor    %ebx,%ebx
  801c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c42:	0f 87 34 ff ff ff    	ja     801b7c <__udivdi3+0x4c>
  801c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c4d:	e9 2a ff ff ff       	jmp    801b7c <__udivdi3+0x4c>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 d2                	test   %edx,%edx
  801c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	75 1c                	jne    801ca8 <__umoddi3+0x48>
  801c8c:	39 f7                	cmp    %esi,%edi
  801c8e:	76 50                	jbe    801ce0 <__umoddi3+0x80>
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	f7 f7                	div    %edi
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	77 52                	ja     801d00 <__umoddi3+0xa0>
  801cae:	0f bd ea             	bsr    %edx,%ebp
  801cb1:	83 f5 1f             	xor    $0x1f,%ebp
  801cb4:	75 5a                	jne    801d10 <__umoddi3+0xb0>
  801cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cba:	0f 82 e0 00 00 00    	jb     801da0 <__umoddi3+0x140>
  801cc0:	39 0c 24             	cmp    %ecx,(%esp)
  801cc3:	0f 86 d7 00 00 00    	jbe    801da0 <__umoddi3+0x140>
  801cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	89 fd                	mov    %edi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0x91>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f7                	div    %edi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f5                	div    %ebp
  801cf7:	89 c8                	mov    %ecx,%eax
  801cf9:	f7 f5                	div    %ebp
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	eb 99                	jmp    801c98 <__umoddi3+0x38>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	8b 34 24             	mov    (%esp),%esi
  801d13:	bf 20 00 00 00       	mov    $0x20,%edi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	29 ef                	sub    %ebp,%edi
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 f9                	mov    %edi,%ecx
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	89 e9                	mov    %ebp,%ecx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 14 24             	mov    %edx,(%esp)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	d3 e3                	shl    %cl,%ebx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	09 d8                	or     %ebx,%eax
  801d4d:	89 d3                	mov    %edx,%ebx
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	f7 34 24             	divl   (%esp)
  801d54:	89 d6                	mov    %edx,%esi
  801d56:	d3 e3                	shl    %cl,%ebx
  801d58:	f7 64 24 04          	mull   0x4(%esp)
  801d5c:	39 d6                	cmp    %edx,%esi
  801d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	72 08                	jb     801d70 <__umoddi3+0x110>
  801d68:	75 11                	jne    801d7b <__umoddi3+0x11b>
  801d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d6e:	73 0b                	jae    801d7b <__umoddi3+0x11b>
  801d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d74:	1b 14 24             	sbb    (%esp),%edx
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7f:	29 da                	sub    %ebx,%edx
  801d81:	19 ce                	sbb    %ecx,%esi
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	d3 ea                	shr    %cl,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	d3 ee                	shr    %cl,%esi
  801d91:	09 d0                	or     %edx,%eax
  801d93:	89 f2                	mov    %esi,%edx
  801d95:	83 c4 1c             	add    $0x1c,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	29 f9                	sub    %edi,%ecx
  801da2:	19 d6                	sbb    %edx,%esi
  801da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dac:	e9 18 ff ff ff       	jmp    801cc9 <__umoddi3+0x69>
