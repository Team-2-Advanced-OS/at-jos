
obj/user/evilhello:     file format elf32-i386


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
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
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
	
	thisenv = envs+ENVX(sys_getenvid());
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 aa 0f 80 00       	push   $0x800faa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 0f 80 00       	push   $0x800fc7
  800113:	e8 f5 01 00 00       	call   80030d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 aa 0f 80 00       	push   $0x800faa
  80018d:	6a 23                	push   $0x23
  80018f:	68 c7 0f 80 00       	push   $0x800fc7
  800194:	e8 74 01 00 00       	call   80030d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 aa 0f 80 00       	push   $0x800faa
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 c7 0f 80 00       	push   $0x800fc7
  8001d6:	e8 32 01 00 00       	call   80030d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 aa 0f 80 00       	push   $0x800faa
  800211:	6a 23                	push   $0x23
  800213:	68 c7 0f 80 00       	push   $0x800fc7
  800218:	e8 f0 00 00 00       	call   80030d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 aa 0f 80 00       	push   $0x800faa
  800253:	6a 23                	push   $0x23
  800255:	68 c7 0f 80 00       	push   $0x800fc7
  80025a:	e8 ae 00 00 00       	call   80030d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 aa 0f 80 00       	push   $0x800faa
  800295:	6a 23                	push   $0x23
  800297:	68 c7 0f 80 00       	push   $0x800fc7
  80029c:	e8 6c 00 00 00       	call   80030d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	be 00 00 00 00       	mov    $0x0,%esi
  8002b4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 17                	jle    800305 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	83 ec 0c             	sub    $0xc,%esp
  8002f1:	50                   	push   %eax
  8002f2:	6a 0c                	push   $0xc
  8002f4:	68 aa 0f 80 00       	push   $0x800faa
  8002f9:	6a 23                	push   $0x23
  8002fb:	68 c7 0f 80 00       	push   $0x800fc7
  800300:	e8 08 00 00 00       	call   80030d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 d8 0f 80 00       	push   $0x800fd8
  800330:	e8 b1 00 00 00       	call   8003e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	e8 54 00 00 00       	call   800395 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800348:	e8 99 00 00 00       	call   8003e6 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	75 1a                	jne    80038c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 1f fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a5:	00 00 00 
	b.cnt = 0;
  8003a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	68 53 03 80 00       	push   $0x800353
  8003c4:	e8 54 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c9:	83 c4 08             	add    $0x8,%esp
  8003cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d8:	50                   	push   %eax
  8003d9:	e8 c4 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	e8 9d ff ff ff       	call   800395 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 1c             	sub    $0x1c,%esp
  800403:	89 c7                	mov    %eax,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800421:	39 d3                	cmp    %edx,%ebx
  800423:	72 05                	jb     80042a <printnum+0x30>
  800425:	39 45 10             	cmp    %eax,0x10(%ebp)
  800428:	77 45                	ja     80046f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	83 ec 0c             	sub    $0xc,%esp
  80042d:	ff 75 18             	pushl  0x18(%ebp)
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800436:	53                   	push   %ebx
  800437:	ff 75 10             	pushl  0x10(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff 75 dc             	pushl  -0x24(%ebp)
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	e8 b2 08 00 00       	call   800d00 <__udivdi3>
  80044e:	83 c4 18             	add    $0x18,%esp
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	89 f2                	mov    %esi,%edx
  800455:	89 f8                	mov    %edi,%eax
  800457:	e8 9e ff ff ff       	call   8003fa <printnum>
  80045c:	83 c4 20             	add    $0x20,%esp
  80045f:	eb 18                	jmp    800479 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	ff d7                	call   *%edi
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	eb 03                	jmp    800472 <printnum+0x78>
  80046f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f e8                	jg     800461 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	e8 9f 09 00 00       	call   800e30 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
}
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ac:	83 fa 01             	cmp    $0x1,%edx
  8004af:	7e 0e                	jle    8004bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 02                	mov    (%edx),%eax
  8004ba:	8b 52 04             	mov    0x4(%edx),%edx
  8004bd:	eb 22                	jmp    8004e1 <getuint+0x38>
	else if (lflag)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 10                	je     8004d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	eb 0e                	jmp    8004e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800509:	50                   	push   %eax
  80050a:	ff 75 10             	pushl  0x10(%ebp)
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 05 00 00 00       	call   80051d <vprintfmt>
	va_end(ap);
}
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052f:	eb 1d                	jmp    80054e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800531:	85 c0                	test   %eax,%eax
  800533:	75 0f                	jne    800544 <vprintfmt+0x27>
				csa = 0x0700;
  800535:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80053c:	07 00 00 
				return;
  80053f:	e9 c4 03 00 00       	jmp    800908 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	50                   	push   %eax
  800549:	ff d6                	call   *%esi
  80054b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054e:	83 c7 01             	add    $0x1,%edi
  800551:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800555:	83 f8 25             	cmp    $0x25,%eax
  800558:	75 d7                	jne    800531 <vprintfmt+0x14>
  80055a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800565:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800573:	ba 00 00 00 00       	mov    $0x0,%edx
  800578:	eb 07                	jmp    800581 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80057d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8d 47 01             	lea    0x1(%edi),%eax
  800584:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800587:	0f b6 07             	movzbl (%edi),%eax
  80058a:	0f b6 c8             	movzbl %al,%ecx
  80058d:	83 e8 23             	sub    $0x23,%eax
  800590:	3c 55                	cmp    $0x55,%al
  800592:	0f 87 55 03 00 00    	ja     8008ed <vprintfmt+0x3d0>
  800598:	0f b6 c0             	movzbl %al,%eax
  80059b:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a9:	eb d6                	jmp    800581 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c3:	83 fa 09             	cmp    $0x9,%edx
  8005c6:	77 39                	ja     800601 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cb:	eb e9                	jmp    8005b6 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005de:	eb 27                	jmp    800607 <vprintfmt+0xea>
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	0f 49 c8             	cmovns %eax,%ecx
  8005ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f3:	eb 8c                	jmp    800581 <vprintfmt+0x64>
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ff:	eb 80                	jmp    800581 <vprintfmt+0x64>
  800601:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800604:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800607:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060b:	0f 89 70 ff ff ff    	jns    800581 <vprintfmt+0x64>
				width = precision, precision = -1;
  800611:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800614:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800617:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80061e:	e9 5e ff ff ff       	jmp    800581 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800623:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800629:	e9 53 ff ff ff       	jmp    800581 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	ff 30                	pushl  (%eax)
  80063d:	ff d6                	call   *%esi
			break;
  80063f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800645:	e9 04 ff ff ff       	jmp    80054e <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 00                	mov    (%eax),%eax
  800655:	99                   	cltd   
  800656:	31 d0                	xor    %edx,%eax
  800658:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065a:	83 f8 08             	cmp    $0x8,%eax
  80065d:	7f 0b                	jg     80066a <vprintfmt+0x14d>
  80065f:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	75 18                	jne    800682 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80066a:	50                   	push   %eax
  80066b:	68 16 10 80 00       	push   $0x801016
  800670:	53                   	push   %ebx
  800671:	56                   	push   %esi
  800672:	e8 89 fe ff ff       	call   800500 <printfmt>
  800677:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067d:	e9 cc fe ff ff       	jmp    80054e <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800682:	52                   	push   %edx
  800683:	68 1f 10 80 00       	push   $0x80101f
  800688:	53                   	push   %ebx
  800689:	56                   	push   %esi
  80068a:	e8 71 fe ff ff       	call   800500 <printfmt>
  80068f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	e9 b4 fe ff ff       	jmp    80054e <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  8006ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b3:	0f 8e 94 00 00 00    	jle    80074d <vprintfmt+0x230>
  8006b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006bd:	0f 84 98 00 00 00    	je     80075b <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c9:	57                   	push   %edi
  8006ca:	e8 c1 02 00 00       	call   800990 <strnlen>
  8006cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d2:	29 c1                	sub    %eax,%ecx
  8006d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e6:	eb 0f                	jmp    8006f7 <vprintfmt+0x1da>
					putch(padc, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f1:	83 ef 01             	sub    $0x1,%edi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 ff                	test   %edi,%edi
  8006f9:	7f ed                	jg     8006e8 <vprintfmt+0x1cb>
  8006fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800701:	85 c9                	test   %ecx,%ecx
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	0f 49 c1             	cmovns %ecx,%eax
  80070b:	29 c1                	sub    %eax,%ecx
  80070d:	89 75 08             	mov    %esi,0x8(%ebp)
  800710:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800713:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800716:	89 cb                	mov    %ecx,%ebx
  800718:	eb 4d                	jmp    800767 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071e:	74 1b                	je     80073b <vprintfmt+0x21e>
  800720:	0f be c0             	movsbl %al,%eax
  800723:	83 e8 20             	sub    $0x20,%eax
  800726:	83 f8 5e             	cmp    $0x5e,%eax
  800729:	76 10                	jbe    80073b <vprintfmt+0x21e>
					putch('?', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	ff 75 0c             	pushl  0xc(%ebp)
  800731:	6a 3f                	push   $0x3f
  800733:	ff 55 08             	call   *0x8(%ebp)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 0d                	jmp    800748 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	52                   	push   %edx
  800742:	ff 55 08             	call   *0x8(%ebp)
  800745:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800748:	83 eb 01             	sub    $0x1,%ebx
  80074b:	eb 1a                	jmp    800767 <vprintfmt+0x24a>
  80074d:	89 75 08             	mov    %esi,0x8(%ebp)
  800750:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800753:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800756:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800759:	eb 0c                	jmp    800767 <vprintfmt+0x24a>
  80075b:	89 75 08             	mov    %esi,0x8(%ebp)
  80075e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800761:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800764:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800767:	83 c7 01             	add    $0x1,%edi
  80076a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076e:	0f be d0             	movsbl %al,%edx
  800771:	85 d2                	test   %edx,%edx
  800773:	74 23                	je     800798 <vprintfmt+0x27b>
  800775:	85 f6                	test   %esi,%esi
  800777:	78 a1                	js     80071a <vprintfmt+0x1fd>
  800779:	83 ee 01             	sub    $0x1,%esi
  80077c:	79 9c                	jns    80071a <vprintfmt+0x1fd>
  80077e:	89 df                	mov    %ebx,%edi
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800786:	eb 18                	jmp    8007a0 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 20                	push   $0x20
  80078e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800790:	83 ef 01             	sub    $0x1,%edi
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 08                	jmp    8007a0 <vprintfmt+0x283>
  800798:	89 df                	mov    %ebx,%edi
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a0:	85 ff                	test   %edi,%edi
  8007a2:	7f e4                	jg     800788 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a7:	e9 a2 fd ff ff       	jmp    80054e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ac:	83 fa 01             	cmp    $0x1,%edx
  8007af:	7e 16                	jle    8007c7 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 08             	lea    0x8(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ba:	8b 50 04             	mov    0x4(%eax),%edx
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c5:	eb 32                	jmp    8007f9 <vprintfmt+0x2dc>
	else if (lflag)
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	74 18                	je     8007e3 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d9:	89 c1                	mov    %eax,%ecx
  8007db:	c1 f9 1f             	sar    $0x1f,%ecx
  8007de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e1:	eb 16                	jmp    8007f9 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 c1                	mov    %eax,%ecx
  8007f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800804:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800808:	79 74                	jns    80087e <vprintfmt+0x361>
				putch('-', putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	53                   	push   %ebx
  80080e:	6a 2d                	push   $0x2d
  800810:	ff d6                	call   *%esi
				num = -(long long) num;
  800812:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800815:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800818:	f7 d8                	neg    %eax
  80081a:	83 d2 00             	adc    $0x0,%edx
  80081d:	f7 da                	neg    %edx
  80081f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800822:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800827:	eb 55                	jmp    80087e <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
  80082c:	e8 78 fc ff ff       	call   8004a9 <getuint>
			base = 10;
  800831:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800836:	eb 46                	jmp    80087e <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
  80083b:	e8 69 fc ff ff       	call   8004a9 <getuint>
      base = 8;
  800840:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800845:	eb 37                	jmp    80087e <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	6a 30                	push   $0x30
  80084d:	ff d6                	call   *%esi
			putch('x', putdat);
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 78                	push   $0x78
  800855:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8d 50 04             	lea    0x4(%eax),%edx
  80085d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800860:	8b 00                	mov    (%eax),%eax
  800862:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800867:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086f:	eb 0d                	jmp    80087e <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
  800874:	e8 30 fc ff ff       	call   8004a9 <getuint>
			base = 16;
  800879:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087e:	83 ec 0c             	sub    $0xc,%esp
  800881:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800885:	57                   	push   %edi
  800886:	ff 75 e0             	pushl  -0x20(%ebp)
  800889:	51                   	push   %ecx
  80088a:	52                   	push   %edx
  80088b:	50                   	push   %eax
  80088c:	89 da                	mov    %ebx,%edx
  80088e:	89 f0                	mov    %esi,%eax
  800890:	e8 65 fb ff ff       	call   8003fa <printnum>
			break;
  800895:	83 c4 20             	add    $0x20,%esp
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089b:	e9 ae fc ff ff       	jmp    80054e <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	51                   	push   %ecx
  8008a5:	ff d6                	call   *%esi
			break;
  8008a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ad:	e9 9c fc ff ff       	jmp    80054e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b2:	83 fa 01             	cmp    $0x1,%edx
  8008b5:	7e 0d                	jle    8008c4 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8d 50 08             	lea    0x8(%eax),%edx
  8008bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	eb 1c                	jmp    8008e0 <vprintfmt+0x3c3>
	else if (lflag)
  8008c4:	85 d2                	test   %edx,%edx
  8008c6:	74 0d                	je     8008d5 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	eb 0b                	jmp    8008e0 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8d 50 04             	lea    0x4(%eax),%edx
  8008db:	89 55 14             	mov    %edx,0x14(%ebp)
  8008de:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008e0:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008e8:	e9 61 fc ff ff       	jmp    80054e <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	6a 25                	push   $0x25
  8008f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	eb 03                	jmp    8008fd <vprintfmt+0x3e0>
  8008fa:	83 ef 01             	sub    $0x1,%edi
  8008fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800901:	75 f7                	jne    8008fa <vprintfmt+0x3dd>
  800903:	e9 46 fc ff ff       	jmp    80054e <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800908:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 18             	sub    $0x18,%esp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800923:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800926:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	74 26                	je     800957 <vsnprintf+0x47>
  800931:	85 d2                	test   %edx,%edx
  800933:	7e 22                	jle    800957 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800935:	ff 75 14             	pushl  0x14(%ebp)
  800938:	ff 75 10             	pushl  0x10(%ebp)
  80093b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093e:	50                   	push   %eax
  80093f:	68 e3 04 80 00       	push   $0x8004e3
  800944:	e8 d4 fb ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800949:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	eb 05                	jmp    80095c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800957:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800964:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800967:	50                   	push   %eax
  800968:	ff 75 10             	pushl  0x10(%ebp)
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	ff 75 08             	pushl  0x8(%ebp)
  800971:	e8 9a ff ff ff       	call   800910 <vsnprintf>
	va_end(ap);

	return rc;
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
  800983:	eb 03                	jmp    800988 <strlen+0x10>
		n++;
  800985:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800988:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098c:	75 f7                	jne    800985 <strlen+0xd>
		n++;
	return n;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	eb 03                	jmp    8009a3 <strnlen+0x13>
		n++;
  8009a0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	74 08                	je     8009af <strnlen+0x1f>
  8009a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ab:	75 f3                	jne    8009a0 <strnlen+0x10>
  8009ad:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	83 c1 01             	add    $0x1,%ecx
  8009c3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ca:	84 db                	test   %bl,%bl
  8009cc:	75 ef                	jne    8009bd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d8:	53                   	push   %ebx
  8009d9:	e8 9a ff ff ff       	call   800978 <strlen>
  8009de:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e1:	ff 75 0c             	pushl  0xc(%ebp)
  8009e4:	01 d8                	add    %ebx,%eax
  8009e6:	50                   	push   %eax
  8009e7:	e8 c5 ff ff ff       	call   8009b1 <strcpy>
	return dst;
}
  8009ec:	89 d8                	mov    %ebx,%eax
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a03:	89 f2                	mov    %esi,%edx
  800a05:	eb 0f                	jmp    800a16 <strncpy+0x23>
		*dst++ = *src;
  800a07:	83 c2 01             	add    $0x1,%edx
  800a0a:	0f b6 01             	movzbl (%ecx),%eax
  800a0d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a10:	80 39 01             	cmpb   $0x1,(%ecx)
  800a13:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a16:	39 da                	cmp    %ebx,%edx
  800a18:	75 ed                	jne    800a07 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1a:	89 f0                	mov    %esi,%eax
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 75 08             	mov    0x8(%ebp),%esi
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a30:	85 d2                	test   %edx,%edx
  800a32:	74 21                	je     800a55 <strlcpy+0x35>
  800a34:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a38:	89 f2                	mov    %esi,%edx
  800a3a:	eb 09                	jmp    800a45 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a45:	39 c2                	cmp    %eax,%edx
  800a47:	74 09                	je     800a52 <strlcpy+0x32>
  800a49:	0f b6 19             	movzbl (%ecx),%ebx
  800a4c:	84 db                	test   %bl,%bl
  800a4e:	75 ec                	jne    800a3c <strlcpy+0x1c>
  800a50:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a52:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a55:	29 f0                	sub    %esi,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a64:	eb 06                	jmp    800a6c <strcmp+0x11>
		p++, q++;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	84 c0                	test   %al,%al
  800a71:	74 04                	je     800a77 <strcmp+0x1c>
  800a73:	3a 02                	cmp    (%edx),%al
  800a75:	74 ef                	je     800a66 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a77:	0f b6 c0             	movzbl %al,%eax
  800a7a:	0f b6 12             	movzbl (%edx),%edx
  800a7d:	29 d0                	sub    %edx,%eax
}
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8b:	89 c3                	mov    %eax,%ebx
  800a8d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a90:	eb 06                	jmp    800a98 <strncmp+0x17>
		n--, p++, q++;
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a98:	39 d8                	cmp    %ebx,%eax
  800a9a:	74 15                	je     800ab1 <strncmp+0x30>
  800a9c:	0f b6 08             	movzbl (%eax),%ecx
  800a9f:	84 c9                	test   %cl,%cl
  800aa1:	74 04                	je     800aa7 <strncmp+0x26>
  800aa3:	3a 0a                	cmp    (%edx),%cl
  800aa5:	74 eb                	je     800a92 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	0f b6 00             	movzbl (%eax),%eax
  800aaa:	0f b6 12             	movzbl (%edx),%edx
  800aad:	29 d0                	sub    %edx,%eax
  800aaf:	eb 05                	jmp    800ab6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac3:	eb 07                	jmp    800acc <strchr+0x13>
		if (*s == c)
  800ac5:	38 ca                	cmp    %cl,%dl
  800ac7:	74 0f                	je     800ad8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	0f b6 10             	movzbl (%eax),%edx
  800acf:	84 d2                	test   %dl,%dl
  800ad1:	75 f2                	jne    800ac5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae4:	eb 03                	jmp    800ae9 <strfind+0xf>
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aec:	38 ca                	cmp    %cl,%dl
  800aee:	74 04                	je     800af4 <strfind+0x1a>
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 f2                	jne    800ae6 <strfind+0xc>
			break;
	return (char *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b02:	85 c9                	test   %ecx,%ecx
  800b04:	74 36                	je     800b3c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b06:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0c:	75 28                	jne    800b36 <memset+0x40>
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 23                	jne    800b36 <memset+0x40>
		c &= 0xFF;
  800b13:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	c1 e3 08             	shl    $0x8,%ebx
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	c1 e6 18             	shl    $0x18,%esi
  800b21:	89 d0                	mov    %edx,%eax
  800b23:	c1 e0 10             	shl    $0x10,%eax
  800b26:	09 f0                	or     %esi,%eax
  800b28:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	09 d0                	or     %edx,%eax
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
  800b31:	fc                   	cld    
  800b32:	f3 ab                	rep stos %eax,%es:(%edi)
  800b34:	eb 06                	jmp    800b3c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	fc                   	cld    
  800b3a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3c:	89 f8                	mov    %edi,%eax
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b51:	39 c6                	cmp    %eax,%esi
  800b53:	73 35                	jae    800b8a <memmove+0x47>
  800b55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b58:	39 d0                	cmp    %edx,%eax
  800b5a:	73 2e                	jae    800b8a <memmove+0x47>
		s += n;
		d += n;
  800b5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	89 d6                	mov    %edx,%esi
  800b61:	09 fe                	or     %edi,%esi
  800b63:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b69:	75 13                	jne    800b7e <memmove+0x3b>
  800b6b:	f6 c1 03             	test   $0x3,%cl
  800b6e:	75 0e                	jne    800b7e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b70:	83 ef 04             	sub    $0x4,%edi
  800b73:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b76:	c1 e9 02             	shr    $0x2,%ecx
  800b79:	fd                   	std    
  800b7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7c:	eb 09                	jmp    800b87 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7e:	83 ef 01             	sub    $0x1,%edi
  800b81:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b84:	fd                   	std    
  800b85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b87:	fc                   	cld    
  800b88:	eb 1d                	jmp    800ba7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8a:	89 f2                	mov    %esi,%edx
  800b8c:	09 c2                	or     %eax,%edx
  800b8e:	f6 c2 03             	test   $0x3,%dl
  800b91:	75 0f                	jne    800ba2 <memmove+0x5f>
  800b93:	f6 c1 03             	test   $0x3,%cl
  800b96:	75 0a                	jne    800ba2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b98:	c1 e9 02             	shr    $0x2,%ecx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	fc                   	cld    
  800b9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba0:	eb 05                	jmp    800ba7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	fc                   	cld    
  800ba5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bae:	ff 75 10             	pushl  0x10(%ebp)
  800bb1:	ff 75 0c             	pushl  0xc(%ebp)
  800bb4:	ff 75 08             	pushl  0x8(%ebp)
  800bb7:	e8 87 ff ff ff       	call   800b43 <memmove>
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc9:	89 c6                	mov    %eax,%esi
  800bcb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bce:	eb 1a                	jmp    800bea <memcmp+0x2c>
		if (*s1 != *s2)
  800bd0:	0f b6 08             	movzbl (%eax),%ecx
  800bd3:	0f b6 1a             	movzbl (%edx),%ebx
  800bd6:	38 d9                	cmp    %bl,%cl
  800bd8:	74 0a                	je     800be4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bda:	0f b6 c1             	movzbl %cl,%eax
  800bdd:	0f b6 db             	movzbl %bl,%ebx
  800be0:	29 d8                	sub    %ebx,%eax
  800be2:	eb 0f                	jmp    800bf3 <memcmp+0x35>
		s1++, s2++;
  800be4:	83 c0 01             	add    $0x1,%eax
  800be7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bea:	39 f0                	cmp    %esi,%eax
  800bec:	75 e2                	jne    800bd0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bfe:	89 c1                	mov    %eax,%ecx
  800c00:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c03:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c07:	eb 0a                	jmp    800c13 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c09:	0f b6 10             	movzbl (%eax),%edx
  800c0c:	39 da                	cmp    %ebx,%edx
  800c0e:	74 07                	je     800c17 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c10:	83 c0 01             	add    $0x1,%eax
  800c13:	39 c8                	cmp    %ecx,%eax
  800c15:	72 f2                	jb     800c09 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c26:	eb 03                	jmp    800c2b <strtol+0x11>
		s++;
  800c28:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2b:	0f b6 01             	movzbl (%ecx),%eax
  800c2e:	3c 20                	cmp    $0x20,%al
  800c30:	74 f6                	je     800c28 <strtol+0xe>
  800c32:	3c 09                	cmp    $0x9,%al
  800c34:	74 f2                	je     800c28 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c36:	3c 2b                	cmp    $0x2b,%al
  800c38:	75 0a                	jne    800c44 <strtol+0x2a>
		s++;
  800c3a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c42:	eb 11                	jmp    800c55 <strtol+0x3b>
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c49:	3c 2d                	cmp    $0x2d,%al
  800c4b:	75 08                	jne    800c55 <strtol+0x3b>
		s++, neg = 1;
  800c4d:	83 c1 01             	add    $0x1,%ecx
  800c50:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c55:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5b:	75 15                	jne    800c72 <strtol+0x58>
  800c5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c60:	75 10                	jne    800c72 <strtol+0x58>
  800c62:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c66:	75 7c                	jne    800ce4 <strtol+0xca>
		s += 2, base = 16;
  800c68:	83 c1 02             	add    $0x2,%ecx
  800c6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c70:	eb 16                	jmp    800c88 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c72:	85 db                	test   %ebx,%ebx
  800c74:	75 12                	jne    800c88 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c76:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7e:	75 08                	jne    800c88 <strtol+0x6e>
		s++, base = 8;
  800c80:	83 c1 01             	add    $0x1,%ecx
  800c83:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c90:	0f b6 11             	movzbl (%ecx),%edx
  800c93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c96:	89 f3                	mov    %esi,%ebx
  800c98:	80 fb 09             	cmp    $0x9,%bl
  800c9b:	77 08                	ja     800ca5 <strtol+0x8b>
			dig = *s - '0';
  800c9d:	0f be d2             	movsbl %dl,%edx
  800ca0:	83 ea 30             	sub    $0x30,%edx
  800ca3:	eb 22                	jmp    800cc7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca8:	89 f3                	mov    %esi,%ebx
  800caa:	80 fb 19             	cmp    $0x19,%bl
  800cad:	77 08                	ja     800cb7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800caf:	0f be d2             	movsbl %dl,%edx
  800cb2:	83 ea 57             	sub    $0x57,%edx
  800cb5:	eb 10                	jmp    800cc7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cba:	89 f3                	mov    %esi,%ebx
  800cbc:	80 fb 19             	cmp    $0x19,%bl
  800cbf:	77 16                	ja     800cd7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc1:	0f be d2             	movsbl %dl,%edx
  800cc4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cca:	7d 0b                	jge    800cd7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ccc:	83 c1 01             	add    $0x1,%ecx
  800ccf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd5:	eb b9                	jmp    800c90 <strtol+0x76>

	if (endptr)
  800cd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdb:	74 0d                	je     800cea <strtol+0xd0>
		*endptr = (char *) s;
  800cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce0:	89 0e                	mov    %ecx,(%esi)
  800ce2:	eb 06                	jmp    800cea <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce4:	85 db                	test   %ebx,%ebx
  800ce6:	74 98                	je     800c80 <strtol+0x66>
  800ce8:	eb 9e                	jmp    800c88 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cea:	89 c2                	mov    %eax,%edx
  800cec:	f7 da                	neg    %edx
  800cee:	85 ff                	test   %edi,%edi
  800cf0:	0f 45 c2             	cmovne %edx,%eax
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

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
