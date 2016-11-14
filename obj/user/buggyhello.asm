
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 aa 0f 80 00       	push   $0x800faa
  800109:	6a 23                	push   $0x23
  80010b:	68 c7 0f 80 00       	push   $0x800fc7
  800110:	e8 f5 01 00 00       	call   80030a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7e 17                	jle    800196 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	6a 04                	push   $0x4
  800185:	68 aa 0f 80 00       	push   $0x800faa
  80018a:	6a 23                	push   $0x23
  80018c:	68 c7 0f 80 00       	push   $0x800fc7
  800191:	e8 74 01 00 00       	call   80030a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 05                	push   $0x5
  8001c7:	68 aa 0f 80 00       	push   $0x800faa
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 c7 0f 80 00       	push   $0x800fc7
  8001d3:	e8 32 01 00 00       	call   80030a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 06                	push   $0x6
  800209:	68 aa 0f 80 00       	push   $0x800faa
  80020e:	6a 23                	push   $0x23
  800210:	68 c7 0f 80 00       	push   $0x800fc7
  800215:	e8 f0 00 00 00       	call   80030a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 08                	push   $0x8
  80024b:	68 aa 0f 80 00       	push   $0x800faa
  800250:	6a 23                	push   $0x23
  800252:	68 c7 0f 80 00       	push   $0x800fc7
  800257:	e8 ae 00 00 00       	call   80030a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 09                	push   $0x9
  80028d:	68 aa 0f 80 00       	push   $0x800faa
  800292:	6a 23                	push   $0x23
  800294:	68 c7 0f 80 00       	push   $0x800fc7
  800299:	e8 6c 00 00 00       	call   80030a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	be 00 00 00 00       	mov    $0x0,%esi
  8002b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0c                	push   $0xc
  8002f1:	68 aa 0f 80 00       	push   $0x800faa
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 c7 0f 80 00       	push   $0x800fc7
  8002fd:	e8 08 00 00 00       	call   80030a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800312:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800318:	e8 00 fe ff ff       	call   80011d <sys_getenvid>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	56                   	push   %esi
  800327:	50                   	push   %eax
  800328:	68 d8 0f 80 00       	push   $0x800fd8
  80032d:	e8 b1 00 00 00       	call   8003e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800332:	83 c4 18             	add    $0x18,%esp
  800335:	53                   	push   %ebx
  800336:	ff 75 10             	pushl  0x10(%ebp)
  800339:	e8 54 00 00 00       	call   800392 <vcprintf>
	cprintf("\n");
  80033e:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800345:	e8 99 00 00 00       	call   8003e3 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x43>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	75 1a                	jne    800389 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 1f fd ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800389:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a2:	00 00 00 
	b.cnt = 0;
  8003a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003af:	ff 75 0c             	pushl  0xc(%ebp)
  8003b2:	ff 75 08             	pushl  0x8(%ebp)
  8003b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bb:	50                   	push   %eax
  8003bc:	68 50 03 80 00       	push   $0x800350
  8003c1:	e8 54 01 00 00       	call   80051a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c6:	83 c4 08             	add    $0x8,%esp
  8003c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	e8 c4 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ec:	50                   	push   %eax
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	e8 9d ff ff ff       	call   800392 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	83 ec 1c             	sub    $0x1c,%esp
  800400:	89 c7                	mov    %eax,%edi
  800402:	89 d6                	mov    %edx,%esi
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800410:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800413:	bb 00 00 00 00       	mov    $0x0,%ebx
  800418:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041e:	39 d3                	cmp    %edx,%ebx
  800420:	72 05                	jb     800427 <printnum+0x30>
  800422:	39 45 10             	cmp    %eax,0x10(%ebp)
  800425:	77 45                	ja     80046c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	pushl  0x18(%ebp)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800433:	53                   	push   %ebx
  800434:	ff 75 10             	pushl  0x10(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff 75 dc             	pushl  -0x24(%ebp)
  800443:	ff 75 d8             	pushl  -0x28(%ebp)
  800446:	e8 b5 08 00 00       	call   800d00 <__udivdi3>
  80044b:	83 c4 18             	add    $0x18,%esp
  80044e:	52                   	push   %edx
  80044f:	50                   	push   %eax
  800450:	89 f2                	mov    %esi,%edx
  800452:	89 f8                	mov    %edi,%eax
  800454:	e8 9e ff ff ff       	call   8003f7 <printnum>
  800459:	83 c4 20             	add    $0x20,%esp
  80045c:	eb 18                	jmp    800476 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	56                   	push   %esi
  800462:	ff 75 18             	pushl  0x18(%ebp)
  800465:	ff d7                	call   *%edi
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	eb 03                	jmp    80046f <printnum+0x78>
  80046c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f e8                	jg     80045e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	56                   	push   %esi
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 a2 09 00 00       	call   800e30 <__umoddi3>
  80048e:	83 c4 14             	add    $0x14,%esp
  800491:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  800498:	50                   	push   %eax
  800499:	ff d7                	call   *%edi
}
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a1:	5b                   	pop    %ebx
  8004a2:	5e                   	pop    %esi
  8004a3:	5f                   	pop    %edi
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a9:	83 fa 01             	cmp    $0x1,%edx
  8004ac:	7e 0e                	jle    8004bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ba:	eb 22                	jmp    8004de <getuint+0x38>
	else if (lflag)
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	74 10                	je     8004d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	eb 0e                	jmp    8004de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ef:	73 0a                	jae    8004fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	88 02                	mov    %al,(%edx)
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800503:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800506:	50                   	push   %eax
  800507:	ff 75 10             	pushl  0x10(%ebp)
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 05 00 00 00       	call   80051a <vprintfmt>
	va_end(ap);
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
  800520:	83 ec 2c             	sub    $0x2c,%esp
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052c:	eb 1d                	jmp    80054b <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80052e:	85 c0                	test   %eax,%eax
  800530:	75 0f                	jne    800541 <vprintfmt+0x27>
				csa = 0x0700;
  800532:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800539:	07 00 00 
				return;
  80053c:	e9 c4 03 00 00       	jmp    800905 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	50                   	push   %eax
  800546:	ff d6                	call   *%esi
  800548:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	83 f8 25             	cmp    $0x25,%eax
  800555:	75 d7                	jne    80052e <vprintfmt+0x14>
  800557:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800562:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800569:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800570:	ba 00 00 00 00       	mov    $0x0,%edx
  800575:	eb 07                	jmp    80057e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80057a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8d 47 01             	lea    0x1(%edi),%eax
  800581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800584:	0f b6 07             	movzbl (%edi),%eax
  800587:	0f b6 c8             	movzbl %al,%ecx
  80058a:	83 e8 23             	sub    $0x23,%eax
  80058d:	3c 55                	cmp    $0x55,%al
  80058f:	0f 87 55 03 00 00    	ja     8008ea <vprintfmt+0x3d0>
  800595:	0f b6 c0             	movzbl %al,%eax
  800598:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a6:	eb d6                	jmp    80057e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c0:	83 fa 09             	cmp    $0x9,%edx
  8005c3:	77 39                	ja     8005fe <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c8:	eb e9                	jmp    8005b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005db:	eb 27                	jmp    800604 <vprintfmt+0xea>
  8005dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	0f 49 c8             	cmovns %eax,%ecx
  8005ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f0:	eb 8c                	jmp    80057e <vprintfmt+0x64>
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fc:	eb 80                	jmp    80057e <vprintfmt+0x64>
  8005fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800601:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800604:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800608:	0f 89 70 ff ff ff    	jns    80057e <vprintfmt+0x64>
				width = precision, precision = -1;
  80060e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800611:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800614:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80061b:	e9 5e ff ff ff       	jmp    80057e <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800620:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800626:	e9 53 ff ff ff       	jmp    80057e <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	ff 30                	pushl  (%eax)
  80063a:	ff d6                	call   *%esi
			break;
  80063c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800642:	e9 04 ff ff ff       	jmp    80054b <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	99                   	cltd   
  800653:	31 d0                	xor    %edx,%eax
  800655:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800657:	83 f8 08             	cmp    $0x8,%eax
  80065a:	7f 0b                	jg     800667 <vprintfmt+0x14d>
  80065c:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800663:	85 d2                	test   %edx,%edx
  800665:	75 18                	jne    80067f <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800667:	50                   	push   %eax
  800668:	68 16 10 80 00       	push   $0x801016
  80066d:	53                   	push   %ebx
  80066e:	56                   	push   %esi
  80066f:	e8 89 fe ff ff       	call   8004fd <printfmt>
  800674:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067a:	e9 cc fe ff ff       	jmp    80054b <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80067f:	52                   	push   %edx
  800680:	68 1f 10 80 00       	push   $0x80101f
  800685:	53                   	push   %ebx
  800686:	56                   	push   %esi
  800687:	e8 71 fe ff ff       	call   8004fd <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800692:	e9 b4 fe ff ff       	jmp    80054b <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  8006a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b0:	0f 8e 94 00 00 00    	jle    80074a <vprintfmt+0x230>
  8006b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ba:	0f 84 98 00 00 00    	je     800758 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c6:	57                   	push   %edi
  8006c7:	e8 c1 02 00 00       	call   80098d <strnlen>
  8006cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cf:	29 c1                	sub    %eax,%ecx
  8006d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	eb 0f                	jmp    8006f4 <vprintfmt+0x1da>
					putch(padc, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 ff                	test   %edi,%edi
  8006f6:	7f ed                	jg     8006e5 <vprintfmt+0x1cb>
  8006f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fe:	85 c9                	test   %ecx,%ecx
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	0f 49 c1             	cmovns %ecx,%eax
  800708:	29 c1                	sub    %eax,%ecx
  80070a:	89 75 08             	mov    %esi,0x8(%ebp)
  80070d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800710:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800713:	89 cb                	mov    %ecx,%ebx
  800715:	eb 4d                	jmp    800764 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071b:	74 1b                	je     800738 <vprintfmt+0x21e>
  80071d:	0f be c0             	movsbl %al,%eax
  800720:	83 e8 20             	sub    $0x20,%eax
  800723:	83 f8 5e             	cmp    $0x5e,%eax
  800726:	76 10                	jbe    800738 <vprintfmt+0x21e>
					putch('?', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	6a 3f                	push   $0x3f
  800730:	ff 55 08             	call   *0x8(%ebp)
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 0d                	jmp    800745 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	52                   	push   %edx
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800745:	83 eb 01             	sub    $0x1,%ebx
  800748:	eb 1a                	jmp    800764 <vprintfmt+0x24a>
  80074a:	89 75 08             	mov    %esi,0x8(%ebp)
  80074d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800750:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800753:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800756:	eb 0c                	jmp    800764 <vprintfmt+0x24a>
  800758:	89 75 08             	mov    %esi,0x8(%ebp)
  80075b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800761:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800764:	83 c7 01             	add    $0x1,%edi
  800767:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076b:	0f be d0             	movsbl %al,%edx
  80076e:	85 d2                	test   %edx,%edx
  800770:	74 23                	je     800795 <vprintfmt+0x27b>
  800772:	85 f6                	test   %esi,%esi
  800774:	78 a1                	js     800717 <vprintfmt+0x1fd>
  800776:	83 ee 01             	sub    $0x1,%esi
  800779:	79 9c                	jns    800717 <vprintfmt+0x1fd>
  80077b:	89 df                	mov    %ebx,%edi
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800783:	eb 18                	jmp    80079d <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 20                	push   $0x20
  80078b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078d:	83 ef 01             	sub    $0x1,%edi
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	eb 08                	jmp    80079d <vprintfmt+0x283>
  800795:	89 df                	mov    %ebx,%edi
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079d:	85 ff                	test   %edi,%edi
  80079f:	7f e4                	jg     800785 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a4:	e9 a2 fd ff ff       	jmp    80054b <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a9:	83 fa 01             	cmp    $0x1,%edx
  8007ac:	7e 16                	jle    8007c4 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 08             	lea    0x8(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 50 04             	mov    0x4(%eax),%edx
  8007ba:	8b 00                	mov    (%eax),%eax
  8007bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c2:	eb 32                	jmp    8007f6 <vprintfmt+0x2dc>
	else if (lflag)
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 18                	je     8007e0 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 c1                	mov    %eax,%ecx
  8007d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007de:	eb 16                	jmp    8007f6 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 c1                	mov    %eax,%ecx
  8007f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800801:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800805:	79 74                	jns    80087b <vprintfmt+0x361>
				putch('-', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 2d                	push   $0x2d
  80080d:	ff d6                	call   *%esi
				num = -(long long) num;
  80080f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800812:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800815:	f7 d8                	neg    %eax
  800817:	83 d2 00             	adc    $0x0,%edx
  80081a:	f7 da                	neg    %edx
  80081c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800824:	eb 55                	jmp    80087b <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 78 fc ff ff       	call   8004a6 <getuint>
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800833:	eb 46                	jmp    80087b <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 69 fc ff ff       	call   8004a6 <getuint>
      base = 8;
  80083d:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800842:	eb 37                	jmp    80087b <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	53                   	push   %ebx
  800848:	6a 30                	push   $0x30
  80084a:	ff d6                	call   *%esi
			putch('x', putdat);
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 78                	push   $0x78
  800852:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800864:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800867:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086c:	eb 0d                	jmp    80087b <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	e8 30 fc ff ff       	call   8004a6 <getuint>
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087b:	83 ec 0c             	sub    $0xc,%esp
  80087e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800882:	57                   	push   %edi
  800883:	ff 75 e0             	pushl  -0x20(%ebp)
  800886:	51                   	push   %ecx
  800887:	52                   	push   %edx
  800888:	50                   	push   %eax
  800889:	89 da                	mov    %ebx,%edx
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	e8 65 fb ff ff       	call   8003f7 <printnum>
			break;
  800892:	83 c4 20             	add    $0x20,%esp
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800898:	e9 ae fc ff ff       	jmp    80054b <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	51                   	push   %ecx
  8008a2:	ff d6                	call   *%esi
			break;
  8008a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008aa:	e9 9c fc ff ff       	jmp    80054b <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008af:	83 fa 01             	cmp    $0x1,%edx
  8008b2:	7e 0d                	jle    8008c1 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 08             	lea    0x8(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bd:	8b 00                	mov    (%eax),%eax
  8008bf:	eb 1c                	jmp    8008dd <vprintfmt+0x3c3>
	else if (lflag)
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	74 0d                	je     8008d2 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8d 50 04             	lea    0x4(%eax),%edx
  8008cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ce:	8b 00                	mov    (%eax),%eax
  8008d0:	eb 0b                	jmp    8008dd <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8d 50 04             	lea    0x4(%eax),%edx
  8008d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008db:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008dd:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008e5:	e9 61 fc ff ff       	jmp    80054b <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	53                   	push   %ebx
  8008ee:	6a 25                	push   $0x25
  8008f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb 03                	jmp    8008fa <vprintfmt+0x3e0>
  8008f7:	83 ef 01             	sub    $0x1,%edi
  8008fa:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008fe:	75 f7                	jne    8008f7 <vprintfmt+0x3dd>
  800900:	e9 46 fc ff ff       	jmp    80054b <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800905:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	83 ec 18             	sub    $0x18,%esp
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800919:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800920:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800923:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092a:	85 c0                	test   %eax,%eax
  80092c:	74 26                	je     800954 <vsnprintf+0x47>
  80092e:	85 d2                	test   %edx,%edx
  800930:	7e 22                	jle    800954 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800932:	ff 75 14             	pushl  0x14(%ebp)
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093b:	50                   	push   %eax
  80093c:	68 e0 04 80 00       	push   $0x8004e0
  800941:	e8 d4 fb ff ff       	call   80051a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800946:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800949:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	eb 05                	jmp    800959 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800961:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800964:	50                   	push   %eax
  800965:	ff 75 10             	pushl  0x10(%ebp)
  800968:	ff 75 0c             	pushl  0xc(%ebp)
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 9a ff ff ff       	call   80090d <vsnprintf>
	va_end(ap);

	return rc;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
  800980:	eb 03                	jmp    800985 <strlen+0x10>
		n++;
  800982:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800985:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800989:	75 f7                	jne    800982 <strlen+0xd>
		n++;
	return n;
}
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	eb 03                	jmp    8009a0 <strnlen+0x13>
		n++;
  80099d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a0:	39 c2                	cmp    %eax,%edx
  8009a2:	74 08                	je     8009ac <strnlen+0x1f>
  8009a4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a8:	75 f3                	jne    80099d <strnlen+0x10>
  8009aa:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b8:	89 c2                	mov    %eax,%edx
  8009ba:	83 c2 01             	add    $0x1,%edx
  8009bd:	83 c1 01             	add    $0x1,%ecx
  8009c0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c7:	84 db                	test   %bl,%bl
  8009c9:	75 ef                	jne    8009ba <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d5:	53                   	push   %ebx
  8009d6:	e8 9a ff ff ff       	call   800975 <strlen>
  8009db:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009de:	ff 75 0c             	pushl  0xc(%ebp)
  8009e1:	01 d8                	add    %ebx,%eax
  8009e3:	50                   	push   %eax
  8009e4:	e8 c5 ff ff ff       	call   8009ae <strcpy>
	return dst;
}
  8009e9:	89 d8                	mov    %ebx,%eax
  8009eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a00:	89 f2                	mov    %esi,%edx
  800a02:	eb 0f                	jmp    800a13 <strncpy+0x23>
		*dst++ = *src;
  800a04:	83 c2 01             	add    $0x1,%edx
  800a07:	0f b6 01             	movzbl (%ecx),%eax
  800a0a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0d:	80 39 01             	cmpb   $0x1,(%ecx)
  800a10:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	75 ed                	jne    800a04 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a17:	89 f0                	mov    %esi,%eax
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 75 08             	mov    0x8(%ebp),%esi
  800a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a28:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2d:	85 d2                	test   %edx,%edx
  800a2f:	74 21                	je     800a52 <strlcpy+0x35>
  800a31:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a35:	89 f2                	mov    %esi,%edx
  800a37:	eb 09                	jmp    800a42 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 c2                	cmp    %eax,%edx
  800a44:	74 09                	je     800a4f <strlcpy+0x32>
  800a46:	0f b6 19             	movzbl (%ecx),%ebx
  800a49:	84 db                	test   %bl,%bl
  800a4b:	75 ec                	jne    800a39 <strlcpy+0x1c>
  800a4d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a52:	29 f0                	sub    %esi,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strcmp+0x11>
		p++, q++;
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a69:	0f b6 01             	movzbl (%ecx),%eax
  800a6c:	84 c0                	test   %al,%al
  800a6e:	74 04                	je     800a74 <strcmp+0x1c>
  800a70:	3a 02                	cmp    (%edx),%al
  800a72:	74 ef                	je     800a63 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a74:	0f b6 c0             	movzbl %al,%eax
  800a77:	0f b6 12             	movzbl (%edx),%edx
  800a7a:	29 d0                	sub    %edx,%eax
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	53                   	push   %ebx
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a88:	89 c3                	mov    %eax,%ebx
  800a8a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8d:	eb 06                	jmp    800a95 <strncmp+0x17>
		n--, p++, q++;
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a95:	39 d8                	cmp    %ebx,%eax
  800a97:	74 15                	je     800aae <strncmp+0x30>
  800a99:	0f b6 08             	movzbl (%eax),%ecx
  800a9c:	84 c9                	test   %cl,%cl
  800a9e:	74 04                	je     800aa4 <strncmp+0x26>
  800aa0:	3a 0a                	cmp    (%edx),%cl
  800aa2:	74 eb                	je     800a8f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa4:	0f b6 00             	movzbl (%eax),%eax
  800aa7:	0f b6 12             	movzbl (%edx),%edx
  800aaa:	29 d0                	sub    %edx,%eax
  800aac:	eb 05                	jmp    800ab3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac0:	eb 07                	jmp    800ac9 <strchr+0x13>
		if (*s == c)
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	74 0f                	je     800ad5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	84 d2                	test   %dl,%dl
  800ace:	75 f2                	jne    800ac2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae1:	eb 03                	jmp    800ae6 <strfind+0xf>
  800ae3:	83 c0 01             	add    $0x1,%eax
  800ae6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae9:	38 ca                	cmp    %cl,%dl
  800aeb:	74 04                	je     800af1 <strfind+0x1a>
  800aed:	84 d2                	test   %dl,%dl
  800aef:	75 f2                	jne    800ae3 <strfind+0xc>
			break;
	return (char *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aff:	85 c9                	test   %ecx,%ecx
  800b01:	74 36                	je     800b39 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b03:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b09:	75 28                	jne    800b33 <memset+0x40>
  800b0b:	f6 c1 03             	test   $0x3,%cl
  800b0e:	75 23                	jne    800b33 <memset+0x40>
		c &= 0xFF;
  800b10:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	c1 e3 08             	shl    $0x8,%ebx
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	c1 e6 18             	shl    $0x18,%esi
  800b1e:	89 d0                	mov    %edx,%eax
  800b20:	c1 e0 10             	shl    $0x10,%eax
  800b23:	09 f0                	or     %esi,%eax
  800b25:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b27:	89 d8                	mov    %ebx,%eax
  800b29:	09 d0                	or     %edx,%eax
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
  800b2e:	fc                   	cld    
  800b2f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b31:	eb 06                	jmp    800b39 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	fc                   	cld    
  800b37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b39:	89 f8                	mov    %edi,%eax
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4e:	39 c6                	cmp    %eax,%esi
  800b50:	73 35                	jae    800b87 <memmove+0x47>
  800b52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b55:	39 d0                	cmp    %edx,%eax
  800b57:	73 2e                	jae    800b87 <memmove+0x47>
		s += n;
		d += n;
  800b59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	09 fe                	or     %edi,%esi
  800b60:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b66:	75 13                	jne    800b7b <memmove+0x3b>
  800b68:	f6 c1 03             	test   $0x3,%cl
  800b6b:	75 0e                	jne    800b7b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b6d:	83 ef 04             	sub    $0x4,%edi
  800b70:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b73:	c1 e9 02             	shr    $0x2,%ecx
  800b76:	fd                   	std    
  800b77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b79:	eb 09                	jmp    800b84 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7b:	83 ef 01             	sub    $0x1,%edi
  800b7e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b81:	fd                   	std    
  800b82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b84:	fc                   	cld    
  800b85:	eb 1d                	jmp    800ba4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b87:	89 f2                	mov    %esi,%edx
  800b89:	09 c2                	or     %eax,%edx
  800b8b:	f6 c2 03             	test   $0x3,%dl
  800b8e:	75 0f                	jne    800b9f <memmove+0x5f>
  800b90:	f6 c1 03             	test   $0x3,%cl
  800b93:	75 0a                	jne    800b9f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b95:	c1 e9 02             	shr    $0x2,%ecx
  800b98:	89 c7                	mov    %eax,%edi
  800b9a:	fc                   	cld    
  800b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9d:	eb 05                	jmp    800ba4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bab:	ff 75 10             	pushl  0x10(%ebp)
  800bae:	ff 75 0c             	pushl  0xc(%ebp)
  800bb1:	ff 75 08             	pushl  0x8(%ebp)
  800bb4:	e8 87 ff ff ff       	call   800b40 <memmove>
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc6:	89 c6                	mov    %eax,%esi
  800bc8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcb:	eb 1a                	jmp    800be7 <memcmp+0x2c>
		if (*s1 != *s2)
  800bcd:	0f b6 08             	movzbl (%eax),%ecx
  800bd0:	0f b6 1a             	movzbl (%edx),%ebx
  800bd3:	38 d9                	cmp    %bl,%cl
  800bd5:	74 0a                	je     800be1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd7:	0f b6 c1             	movzbl %cl,%eax
  800bda:	0f b6 db             	movzbl %bl,%ebx
  800bdd:	29 d8                	sub    %ebx,%eax
  800bdf:	eb 0f                	jmp    800bf0 <memcmp+0x35>
		s1++, s2++;
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be7:	39 f0                	cmp    %esi,%eax
  800be9:	75 e2                	jne    800bcd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bfb:	89 c1                	mov    %eax,%ecx
  800bfd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c00:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c04:	eb 0a                	jmp    800c10 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c06:	0f b6 10             	movzbl (%eax),%edx
  800c09:	39 da                	cmp    %ebx,%edx
  800c0b:	74 07                	je     800c14 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0d:	83 c0 01             	add    $0x1,%eax
  800c10:	39 c8                	cmp    %ecx,%eax
  800c12:	72 f2                	jb     800c06 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c14:	5b                   	pop    %ebx
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c23:	eb 03                	jmp    800c28 <strtol+0x11>
		s++;
  800c25:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c28:	0f b6 01             	movzbl (%ecx),%eax
  800c2b:	3c 20                	cmp    $0x20,%al
  800c2d:	74 f6                	je     800c25 <strtol+0xe>
  800c2f:	3c 09                	cmp    $0x9,%al
  800c31:	74 f2                	je     800c25 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c33:	3c 2b                	cmp    $0x2b,%al
  800c35:	75 0a                	jne    800c41 <strtol+0x2a>
		s++;
  800c37:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3f:	eb 11                	jmp    800c52 <strtol+0x3b>
  800c41:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c46:	3c 2d                	cmp    $0x2d,%al
  800c48:	75 08                	jne    800c52 <strtol+0x3b>
		s++, neg = 1;
  800c4a:	83 c1 01             	add    $0x1,%ecx
  800c4d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c58:	75 15                	jne    800c6f <strtol+0x58>
  800c5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5d:	75 10                	jne    800c6f <strtol+0x58>
  800c5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c63:	75 7c                	jne    800ce1 <strtol+0xca>
		s += 2, base = 16;
  800c65:	83 c1 02             	add    $0x2,%ecx
  800c68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6d:	eb 16                	jmp    800c85 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c6f:	85 db                	test   %ebx,%ebx
  800c71:	75 12                	jne    800c85 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c73:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c78:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7b:	75 08                	jne    800c85 <strtol+0x6e>
		s++, base = 8;
  800c7d:	83 c1 01             	add    $0x1,%ecx
  800c80:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c8d:	0f b6 11             	movzbl (%ecx),%edx
  800c90:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c93:	89 f3                	mov    %esi,%ebx
  800c95:	80 fb 09             	cmp    $0x9,%bl
  800c98:	77 08                	ja     800ca2 <strtol+0x8b>
			dig = *s - '0';
  800c9a:	0f be d2             	movsbl %dl,%edx
  800c9d:	83 ea 30             	sub    $0x30,%edx
  800ca0:	eb 22                	jmp    800cc4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca5:	89 f3                	mov    %esi,%ebx
  800ca7:	80 fb 19             	cmp    $0x19,%bl
  800caa:	77 08                	ja     800cb4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cac:	0f be d2             	movsbl %dl,%edx
  800caf:	83 ea 57             	sub    $0x57,%edx
  800cb2:	eb 10                	jmp    800cc4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	80 fb 19             	cmp    $0x19,%bl
  800cbc:	77 16                	ja     800cd4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cbe:	0f be d2             	movsbl %dl,%edx
  800cc1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc7:	7d 0b                	jge    800cd4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc9:	83 c1 01             	add    $0x1,%ecx
  800ccc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd2:	eb b9                	jmp    800c8d <strtol+0x76>

	if (endptr)
  800cd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd8:	74 0d                	je     800ce7 <strtol+0xd0>
		*endptr = (char *) s;
  800cda:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdd:	89 0e                	mov    %ecx,(%esi)
  800cdf:	eb 06                	jmp    800ce7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	85 db                	test   %ebx,%ebx
  800ce3:	74 98                	je     800c7d <strtol+0x66>
  800ce5:	eb 9e                	jmp    800c85 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	f7 da                	neg    %edx
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	0f 45 c2             	cmovne %edx,%eax
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
  800cf5:	66 90                	xchg   %ax,%ax
  800cf7:	66 90                	xchg   %ax,%ax
  800cf9:	66 90                	xchg   %ax,%ax
  800cfb:	66 90                	xchg   %ax,%ax
  800cfd:	66 90                	xchg   %ax,%ax
  800cff:	90                   	nop

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 f6                	test   %esi,%esi
  800d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	75 3d                	jne    800d60 <__udivdi3+0x60>
  800d23:	39 cf                	cmp    %ecx,%edi
  800d25:	0f 87 c5 00 00 00    	ja     800df0 <__udivdi3+0xf0>
  800d2b:	85 ff                	test   %edi,%edi
  800d2d:	89 fd                	mov    %edi,%ebp
  800d2f:	75 0b                	jne    800d3c <__udivdi3+0x3c>
  800d31:	b8 01 00 00 00       	mov    $0x1,%eax
  800d36:	31 d2                	xor    %edx,%edx
  800d38:	f7 f7                	div    %edi
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	89 c8                	mov    %ecx,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f5                	div    %ebp
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	f7 f5                	div    %ebp
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	89 fa                	mov    %edi,%edx
  800d50:	83 c4 1c             	add    $0x1c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
  800d58:	90                   	nop
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 ce                	cmp    %ecx,%esi
  800d62:	77 74                	ja     800dd8 <__udivdi3+0xd8>
  800d64:	0f bd fe             	bsr    %esi,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0x108>
  800d70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 c5                	mov    %eax,%ebp
  800d79:	29 fb                	sub    %edi,%ebx
  800d7b:	d3 e6                	shl    %cl,%esi
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	d3 ed                	shr    %cl,%ebp
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	09 ee                	or     %ebp,%esi
  800d87:	89 d9                	mov    %ebx,%ecx
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	89 d5                	mov    %edx,%ebp
  800d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d93:	d3 ed                	shr    %cl,%ebp
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e2                	shl    %cl,%edx
  800d99:	89 d9                	mov    %ebx,%ecx
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	09 c2                	or     %eax,%edx
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	89 ea                	mov    %ebp,%edx
  800da3:	f7 f6                	div    %esi
  800da5:	89 d5                	mov    %edx,%ebp
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	f7 64 24 0c          	mull   0xc(%esp)
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	72 10                	jb     800dc1 <__udivdi3+0xc1>
  800db1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 07                	jae    800dc4 <__udivdi3+0xc4>
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	75 03                	jne    800dc4 <__udivdi3+0xc4>
  800dc1:	83 eb 01             	sub    $0x1,%ebx
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	83 c4 1c             	add    $0x1c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
  800dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd8:	31 ff                	xor    %edi,%edi
  800dda:	31 db                	xor    %ebx,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	f7 f7                	div    %edi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 ce                	cmp    %ecx,%esi
  800e0a:	72 0c                	jb     800e18 <__udivdi3+0x118>
  800e0c:	31 db                	xor    %ebx,%ebx
  800e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e12:	0f 87 34 ff ff ff    	ja     800d4c <__udivdi3+0x4c>
  800e18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e1d:	e9 2a ff ff ff       	jmp    800d4c <__udivdi3+0x4c>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 d2                	test   %edx,%edx
  800e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	89 3c 24             	mov    %edi,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	75 1c                	jne    800e78 <__umoddi3+0x48>
  800e5c:	39 f7                	cmp    %esi,%edi
  800e5e:	76 50                	jbe    800eb0 <__umoddi3+0x80>
  800e60:	89 c8                	mov    %ecx,%eax
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	f7 f7                	div    %edi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	77 52                	ja     800ed0 <__umoddi3+0xa0>
  800e7e:	0f bd ea             	bsr    %edx,%ebp
  800e81:	83 f5 1f             	xor    $0x1f,%ebp
  800e84:	75 5a                	jne    800ee0 <__umoddi3+0xb0>
  800e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e8a:	0f 82 e0 00 00 00    	jb     800f70 <__umoddi3+0x140>
  800e90:	39 0c 24             	cmp    %ecx,(%esp)
  800e93:	0f 86 d7 00 00 00    	jbe    800f70 <__umoddi3+0x140>
  800e99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	85 ff                	test   %edi,%edi
  800eb2:	89 fd                	mov    %edi,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x91>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c5                	mov    %eax,%ebp
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f5                	div    %ebp
  800ec7:	89 c8                	mov    %ecx,%eax
  800ec9:	f7 f5                	div    %ebp
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 99                	jmp    800e68 <__umoddi3+0x38>
  800ecf:	90                   	nop
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	8b 34 24             	mov    (%esp),%esi
  800ee3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	29 ef                	sub    %ebp,%edi
  800eec:	d3 e0                	shl    %cl,%eax
  800eee:	89 f9                	mov    %edi,%ecx
  800ef0:	89 f2                	mov    %esi,%edx
  800ef2:	d3 ea                	shr    %cl,%edx
  800ef4:	89 e9                	mov    %ebp,%ecx
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 14 24             	mov    %edx,(%esp)
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	d3 e3                	shl    %cl,%ebx
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 d0                	mov    %edx,%eax
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	09 d8                	or     %ebx,%eax
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	f7 34 24             	divl   (%esp)
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	d3 e3                	shl    %cl,%ebx
  800f28:	f7 64 24 04          	mull   0x4(%esp)
  800f2c:	39 d6                	cmp    %edx,%esi
  800f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f32:	89 d1                	mov    %edx,%ecx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	72 08                	jb     800f40 <__umoddi3+0x110>
  800f38:	75 11                	jne    800f4b <__umoddi3+0x11b>
  800f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f3e:	73 0b                	jae    800f4b <__umoddi3+0x11b>
  800f40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f44:	1b 14 24             	sbb    (%esp),%edx
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	19 ce                	sbb    %ecx,%esi
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	d3 e0                	shl    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	09 d0                	or     %edx,%eax
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	29 f9                	sub    %edi,%ecx
  800f72:	19 d6                	sbb    %edx,%esi
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	e9 18 ff ff ff       	jmp    800e99 <__umoddi3+0x69>
