
obj/user/faultwritekernel.debug:     file format elf32-i386


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
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 6b 05 00 00       	call   8005fe <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
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
  800107:	68 2a 23 80 00       	push   $0x80232a
  80010c:	6a 23                	push   $0x23
  80010e:	68 47 23 80 00       	push   $0x802347
  800113:	e8 95 14 00 00       	call   8015ad <_panic>

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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
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
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800188:	68 2a 23 80 00       	push   $0x80232a
  80018d:	6a 23                	push   $0x23
  80018f:	68 47 23 80 00       	push   $0x802347
  800194:	e8 14 14 00 00       	call   8015ad <_panic>

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
  8001ca:	68 2a 23 80 00       	push   $0x80232a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 47 23 80 00       	push   $0x802347
  8001d6:	e8 d2 13 00 00       	call   8015ad <_panic>

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
  80020c:	68 2a 23 80 00       	push   $0x80232a
  800211:	6a 23                	push   $0x23
  800213:	68 47 23 80 00       	push   $0x802347
  800218:	e8 90 13 00 00       	call   8015ad <_panic>

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
  80024e:	68 2a 23 80 00       	push   $0x80232a
  800253:	6a 23                	push   $0x23
  800255:	68 47 23 80 00       	push   $0x802347
  80025a:	e8 4e 13 00 00       	call   8015ad <_panic>

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

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 2a 23 80 00       	push   $0x80232a
  800295:	6a 23                	push   $0x23
  800297:	68 47 23 80 00       	push   $0x802347
  80029c:	e8 0c 13 00 00       	call   8015ad <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 2a 23 80 00       	push   $0x80232a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 47 23 80 00       	push   $0x802347
  8002de:	e8 ca 12 00 00       	call   8015ad <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 2a 23 80 00       	push   $0x80232a
  80033b:	6a 23                	push   $0x23
  80033d:	68 47 23 80 00       	push   $0x802347
  800342:	e8 66 12 00 00       	call   8015ad <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800377:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	89 df                	mov    %ebx,%edi
  800389:	89 de                	mov    %ebx,%esi
  80038b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80038d:	85 c0                	test   %eax,%eax
  80038f:	7e 17                	jle    8003a8 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	50                   	push   %eax
  800395:	6a 0f                	push   $0xf
  800397:	68 2a 23 80 00       	push   $0x80232a
  80039c:	6a 23                	push   $0x23
  80039e:	68 47 23 80 00       	push   $0x802347
  8003a3:	e8 05 12 00 00       	call   8015ad <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8003a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ab:	5b                   	pop    %ebx
  8003ac:	5e                   	pop    %esi
  8003ad:	5f                   	pop    %edi
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	57                   	push   %edi
  8003b4:	56                   	push   %esi
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003be:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	89 df                	mov    %ebx,%edi
  8003cb:	89 de                	mov    %ebx,%esi
  8003cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	7e 17                	jle    8003ea <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d3:	83 ec 0c             	sub    $0xc,%esp
  8003d6:	50                   	push   %eax
  8003d7:	6a 10                	push   $0x10
  8003d9:	68 2a 23 80 00       	push   $0x80232a
  8003de:	6a 23                	push   $0x23
  8003e0:	68 47 23 80 00       	push   $0x802347
  8003e5:	e8 c3 11 00 00       	call   8015ad <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8003ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ed:	5b                   	pop    %ebx
  8003ee:	5e                   	pop    %esi
  8003ef:	5f                   	pop    %edi
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800400:	b8 11 00 00 00       	mov    $0x11,%eax
  800405:	8b 55 08             	mov    0x8(%ebp),%edx
  800408:	89 cb                	mov    %ecx,%ebx
  80040a:	89 cf                	mov    %ecx,%edi
  80040c:	89 ce                	mov    %ecx,%esi
  80040e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800410:	85 c0                	test   %eax,%eax
  800412:	7e 17                	jle    80042b <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	50                   	push   %eax
  800418:	6a 11                	push   $0x11
  80041a:	68 2a 23 80 00       	push   $0x80232a
  80041f:	6a 23                	push   $0x23
  800421:	68 47 23 80 00       	push   $0x802347
  800426:	e8 82 11 00 00       	call   8015ad <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  80042b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042e:	5b                   	pop    %ebx
  80042f:	5e                   	pop    %esi
  800430:	5f                   	pop    %edi
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	05 00 00 00 30       	add    $0x30000000,%eax
  80043e:	c1 e8 0c             	shr    $0xc,%eax
}
  800441:	5d                   	pop    %ebp
  800442:	c3                   	ret    

00800443 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
  800449:	05 00 00 00 30       	add    $0x30000000,%eax
  80044e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800453:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800460:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800465:	89 c2                	mov    %eax,%edx
  800467:	c1 ea 16             	shr    $0x16,%edx
  80046a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800471:	f6 c2 01             	test   $0x1,%dl
  800474:	74 11                	je     800487 <fd_alloc+0x2d>
  800476:	89 c2                	mov    %eax,%edx
  800478:	c1 ea 0c             	shr    $0xc,%edx
  80047b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800482:	f6 c2 01             	test   $0x1,%dl
  800485:	75 09                	jne    800490 <fd_alloc+0x36>
			*fd_store = fd;
  800487:	89 01                	mov    %eax,(%ecx)
			return 0;
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	eb 17                	jmp    8004a7 <fd_alloc+0x4d>
  800490:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800495:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80049a:	75 c9                	jne    800465 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80049c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8004a2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004af:	83 f8 1f             	cmp    $0x1f,%eax
  8004b2:	77 36                	ja     8004ea <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004b4:	c1 e0 0c             	shl    $0xc,%eax
  8004b7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004bc:	89 c2                	mov    %eax,%edx
  8004be:	c1 ea 16             	shr    $0x16,%edx
  8004c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c8:	f6 c2 01             	test   $0x1,%dl
  8004cb:	74 24                	je     8004f1 <fd_lookup+0x48>
  8004cd:	89 c2                	mov    %eax,%edx
  8004cf:	c1 ea 0c             	shr    $0xc,%edx
  8004d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004d9:	f6 c2 01             	test   $0x1,%dl
  8004dc:	74 1a                	je     8004f8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e1:	89 02                	mov    %eax,(%edx)
	return 0;
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	eb 13                	jmp    8004fd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ef:	eb 0c                	jmp    8004fd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f6:	eb 05                	jmp    8004fd <fd_lookup+0x54>
  8004f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800508:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80050d:	eb 13                	jmp    800522 <dev_lookup+0x23>
  80050f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800512:	39 08                	cmp    %ecx,(%eax)
  800514:	75 0c                	jne    800522 <dev_lookup+0x23>
			*dev = devtab[i];
  800516:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800519:	89 01                	mov    %eax,(%ecx)
			return 0;
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	eb 2e                	jmp    800550 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800522:	8b 02                	mov    (%edx),%eax
  800524:	85 c0                	test   %eax,%eax
  800526:	75 e7                	jne    80050f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800528:	a1 08 40 80 00       	mov    0x804008,%eax
  80052d:	8b 40 48             	mov    0x48(%eax),%eax
  800530:	83 ec 04             	sub    $0x4,%esp
  800533:	51                   	push   %ecx
  800534:	50                   	push   %eax
  800535:	68 58 23 80 00       	push   $0x802358
  80053a:	e8 47 11 00 00       	call   801686 <cprintf>
	*dev = 0;
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800542:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 10             	sub    $0x10,%esp
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80056a:	c1 e8 0c             	shr    $0xc,%eax
  80056d:	50                   	push   %eax
  80056e:	e8 36 ff ff ff       	call   8004a9 <fd_lookup>
  800573:	83 c4 08             	add    $0x8,%esp
  800576:	85 c0                	test   %eax,%eax
  800578:	78 05                	js     80057f <fd_close+0x2d>
	    || fd != fd2)
  80057a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80057d:	74 0c                	je     80058b <fd_close+0x39>
		return (must_exist ? r : 0);
  80057f:	84 db                	test   %bl,%bl
  800581:	ba 00 00 00 00       	mov    $0x0,%edx
  800586:	0f 44 c2             	cmove  %edx,%eax
  800589:	eb 41                	jmp    8005cc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 36                	pushl  (%esi)
  800594:	e8 66 ff ff ff       	call   8004ff <dev_lookup>
  800599:	89 c3                	mov    %eax,%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	78 1a                	js     8005bc <fd_close+0x6a>
		if (dev->dev_close)
  8005a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8005a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	74 0b                	je     8005bc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	56                   	push   %esi
  8005b5:	ff d0                	call   *%eax
  8005b7:	89 c3                	mov    %eax,%ebx
  8005b9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	56                   	push   %esi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 1c fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	89 d8                	mov    %ebx,%eax
}
  8005cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005cf:	5b                   	pop    %ebx
  8005d0:	5e                   	pop    %esi
  8005d1:	5d                   	pop    %ebp
  8005d2:	c3                   	ret    

008005d3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005d3:	55                   	push   %ebp
  8005d4:	89 e5                	mov    %esp,%ebp
  8005d6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 08             	pushl  0x8(%ebp)
  8005e0:	e8 c4 fe ff ff       	call   8004a9 <fd_lookup>
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	78 10                	js     8005fc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	6a 01                	push   $0x1
  8005f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8005f4:	e8 59 ff ff ff       	call   800552 <fd_close>
  8005f9:	83 c4 10             	add    $0x10,%esp
}
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    

008005fe <close_all>:

void
close_all(void)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	53                   	push   %ebx
  800602:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800605:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	53                   	push   %ebx
  80060e:	e8 c0 ff ff ff       	call   8005d3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800613:	83 c3 01             	add    $0x1,%ebx
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	83 fb 20             	cmp    $0x20,%ebx
  80061c:	75 ec                	jne    80060a <close_all+0xc>
		close(i);
}
  80061e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800621:	c9                   	leave  
  800622:	c3                   	ret    

00800623 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	57                   	push   %edi
  800627:	56                   	push   %esi
  800628:	53                   	push   %ebx
  800629:	83 ec 2c             	sub    $0x2c,%esp
  80062c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80062f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800632:	50                   	push   %eax
  800633:	ff 75 08             	pushl  0x8(%ebp)
  800636:	e8 6e fe ff ff       	call   8004a9 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	85 c0                	test   %eax,%eax
  800640:	0f 88 c1 00 00 00    	js     800707 <dup+0xe4>
		return r;
	close(newfdnum);
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	56                   	push   %esi
  80064a:	e8 84 ff ff ff       	call   8005d3 <close>

	newfd = INDEX2FD(newfdnum);
  80064f:	89 f3                	mov    %esi,%ebx
  800651:	c1 e3 0c             	shl    $0xc,%ebx
  800654:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80065a:	83 c4 04             	add    $0x4,%esp
  80065d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800660:	e8 de fd ff ff       	call   800443 <fd2data>
  800665:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800667:	89 1c 24             	mov    %ebx,(%esp)
  80066a:	e8 d4 fd ff ff       	call   800443 <fd2data>
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800675:	89 f8                	mov    %edi,%eax
  800677:	c1 e8 16             	shr    $0x16,%eax
  80067a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800681:	a8 01                	test   $0x1,%al
  800683:	74 37                	je     8006bc <dup+0x99>
  800685:	89 f8                	mov    %edi,%eax
  800687:	c1 e8 0c             	shr    $0xc,%eax
  80068a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800691:	f6 c2 01             	test   $0x1,%dl
  800694:	74 26                	je     8006bc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800696:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a5:	50                   	push   %eax
  8006a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006a9:	6a 00                	push   $0x0
  8006ab:	57                   	push   %edi
  8006ac:	6a 00                	push   $0x0
  8006ae:	e8 ee fa ff ff       	call   8001a1 <sys_page_map>
  8006b3:	89 c7                	mov    %eax,%edi
  8006b5:	83 c4 20             	add    $0x20,%esp
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	78 2e                	js     8006ea <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bf:	89 d0                	mov    %edx,%eax
  8006c1:	c1 e8 0c             	shr    $0xc,%eax
  8006c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006cb:	83 ec 0c             	sub    $0xc,%esp
  8006ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8006d3:	50                   	push   %eax
  8006d4:	53                   	push   %ebx
  8006d5:	6a 00                	push   $0x0
  8006d7:	52                   	push   %edx
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 c2 fa ff ff       	call   8001a1 <sys_page_map>
  8006df:	89 c7                	mov    %eax,%edi
  8006e1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006e4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e6:	85 ff                	test   %edi,%edi
  8006e8:	79 1d                	jns    800707 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 00                	push   $0x0
  8006f0:	e8 ee fa ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006fb:	6a 00                	push   $0x0
  8006fd:	e8 e1 fa ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	89 f8                	mov    %edi,%eax
}
  800707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070a:	5b                   	pop    %ebx
  80070b:	5e                   	pop    %esi
  80070c:	5f                   	pop    %edi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	83 ec 14             	sub    $0x14,%esp
  800716:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800719:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	53                   	push   %ebx
  80071e:	e8 86 fd ff ff       	call   8004a9 <fd_lookup>
  800723:	83 c4 08             	add    $0x8,%esp
  800726:	89 c2                	mov    %eax,%edx
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 6d                	js     800799 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	ff 30                	pushl  (%eax)
  800738:	e8 c2 fd ff ff       	call   8004ff <dev_lookup>
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	85 c0                	test   %eax,%eax
  800742:	78 4c                	js     800790 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800744:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800747:	8b 42 08             	mov    0x8(%edx),%eax
  80074a:	83 e0 03             	and    $0x3,%eax
  80074d:	83 f8 01             	cmp    $0x1,%eax
  800750:	75 21                	jne    800773 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800752:	a1 08 40 80 00       	mov    0x804008,%eax
  800757:	8b 40 48             	mov    0x48(%eax),%eax
  80075a:	83 ec 04             	sub    $0x4,%esp
  80075d:	53                   	push   %ebx
  80075e:	50                   	push   %eax
  80075f:	68 99 23 80 00       	push   $0x802399
  800764:	e8 1d 0f 00 00       	call   801686 <cprintf>
		return -E_INVAL;
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800771:	eb 26                	jmp    800799 <read+0x8a>
	}
	if (!dev->dev_read)
  800773:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800776:	8b 40 08             	mov    0x8(%eax),%eax
  800779:	85 c0                	test   %eax,%eax
  80077b:	74 17                	je     800794 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80077d:	83 ec 04             	sub    $0x4,%esp
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	52                   	push   %edx
  800787:	ff d0                	call   *%eax
  800789:	89 c2                	mov    %eax,%edx
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 09                	jmp    800799 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800790:	89 c2                	mov    %eax,%edx
  800792:	eb 05                	jmp    800799 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800794:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800799:	89 d0                	mov    %edx,%eax
  80079b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	57                   	push   %edi
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	83 ec 0c             	sub    $0xc,%esp
  8007a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b4:	eb 21                	jmp    8007d7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b6:	83 ec 04             	sub    $0x4,%esp
  8007b9:	89 f0                	mov    %esi,%eax
  8007bb:	29 d8                	sub    %ebx,%eax
  8007bd:	50                   	push   %eax
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	03 45 0c             	add    0xc(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	57                   	push   %edi
  8007c5:	e8 45 ff ff ff       	call   80070f <read>
		if (m < 0)
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 10                	js     8007e1 <readn+0x41>
			return m;
		if (m == 0)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 0a                	je     8007df <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d5:	01 c3                	add    %eax,%ebx
  8007d7:	39 f3                	cmp    %esi,%ebx
  8007d9:	72 db                	jb     8007b6 <readn+0x16>
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	eb 02                	jmp    8007e1 <readn+0x41>
  8007df:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 14             	sub    $0x14,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f6:	50                   	push   %eax
  8007f7:	53                   	push   %ebx
  8007f8:	e8 ac fc ff ff       	call   8004a9 <fd_lookup>
  8007fd:	83 c4 08             	add    $0x8,%esp
  800800:	89 c2                	mov    %eax,%edx
  800802:	85 c0                	test   %eax,%eax
  800804:	78 68                	js     80086e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	ff 30                	pushl  (%eax)
  800812:	e8 e8 fc ff ff       	call   8004ff <dev_lookup>
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 47                	js     800865 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800821:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800825:	75 21                	jne    800848 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800827:	a1 08 40 80 00       	mov    0x804008,%eax
  80082c:	8b 40 48             	mov    0x48(%eax),%eax
  80082f:	83 ec 04             	sub    $0x4,%esp
  800832:	53                   	push   %ebx
  800833:	50                   	push   %eax
  800834:	68 b5 23 80 00       	push   $0x8023b5
  800839:	e8 48 0e 00 00       	call   801686 <cprintf>
		return -E_INVAL;
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800846:	eb 26                	jmp    80086e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800848:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084b:	8b 52 0c             	mov    0xc(%edx),%edx
  80084e:	85 d2                	test   %edx,%edx
  800850:	74 17                	je     800869 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800852:	83 ec 04             	sub    $0x4,%esp
  800855:	ff 75 10             	pushl  0x10(%ebp)
  800858:	ff 75 0c             	pushl  0xc(%ebp)
  80085b:	50                   	push   %eax
  80085c:	ff d2                	call   *%edx
  80085e:	89 c2                	mov    %eax,%edx
  800860:	83 c4 10             	add    $0x10,%esp
  800863:	eb 09                	jmp    80086e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800865:	89 c2                	mov    %eax,%edx
  800867:	eb 05                	jmp    80086e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800869:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80086e:	89 d0                	mov    %edx,%eax
  800870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <seek>:

int
seek(int fdnum, off_t offset)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80087b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 22 fc ff ff       	call   8004a9 <fd_lookup>
  800887:	83 c4 08             	add    $0x8,%esp
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 0e                	js     80089c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80088e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	53                   	push   %ebx
  8008a2:	83 ec 14             	sub    $0x14,%esp
  8008a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ab:	50                   	push   %eax
  8008ac:	53                   	push   %ebx
  8008ad:	e8 f7 fb ff ff       	call   8004a9 <fd_lookup>
  8008b2:	83 c4 08             	add    $0x8,%esp
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 65                	js     800920 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c5:	ff 30                	pushl  (%eax)
  8008c7:	e8 33 fc ff ff       	call   8004ff <dev_lookup>
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 44                	js     800917 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008da:	75 21                	jne    8008fd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008dc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e1:	8b 40 48             	mov    0x48(%eax),%eax
  8008e4:	83 ec 04             	sub    $0x4,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	50                   	push   %eax
  8008e9:	68 78 23 80 00       	push   $0x802378
  8008ee:	e8 93 0d 00 00       	call   801686 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008fb:	eb 23                	jmp    800920 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800900:	8b 52 18             	mov    0x18(%edx),%edx
  800903:	85 d2                	test   %edx,%edx
  800905:	74 14                	je     80091b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	50                   	push   %eax
  80090e:	ff d2                	call   *%edx
  800910:	89 c2                	mov    %eax,%edx
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 09                	jmp    800920 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800917:	89 c2                	mov    %eax,%edx
  800919:	eb 05                	jmp    800920 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80091b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800920:	89 d0                	mov    %edx,%eax
  800922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 14             	sub    $0x14,%esp
  80092e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800931:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800934:	50                   	push   %eax
  800935:	ff 75 08             	pushl  0x8(%ebp)
  800938:	e8 6c fb ff ff       	call   8004a9 <fd_lookup>
  80093d:	83 c4 08             	add    $0x8,%esp
  800940:	89 c2                	mov    %eax,%edx
  800942:	85 c0                	test   %eax,%eax
  800944:	78 58                	js     80099e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094c:	50                   	push   %eax
  80094d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800950:	ff 30                	pushl  (%eax)
  800952:	e8 a8 fb ff ff       	call   8004ff <dev_lookup>
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	85 c0                	test   %eax,%eax
  80095c:	78 37                	js     800995 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800965:	74 32                	je     800999 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800967:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80096a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800971:	00 00 00 
	stat->st_isdir = 0;
  800974:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80097b:	00 00 00 
	stat->st_dev = dev;
  80097e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	53                   	push   %ebx
  800988:	ff 75 f0             	pushl  -0x10(%ebp)
  80098b:	ff 50 14             	call   *0x14(%eax)
  80098e:	89 c2                	mov    %eax,%edx
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb 09                	jmp    80099e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800995:	89 c2                	mov    %eax,%edx
  800997:	eb 05                	jmp    80099e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800999:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	6a 00                	push   $0x0
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 0c 02 00 00       	call   800bc3 <open>
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	83 c4 10             	add    $0x10,%esp
  8009bc:	85 c0                	test   %eax,%eax
  8009be:	78 1b                	js     8009db <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009c0:	83 ec 08             	sub    $0x8,%esp
  8009c3:	ff 75 0c             	pushl  0xc(%ebp)
  8009c6:	50                   	push   %eax
  8009c7:	e8 5b ff ff ff       	call   800927 <fstat>
  8009cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ce:	89 1c 24             	mov    %ebx,(%esp)
  8009d1:	e8 fd fb ff ff       	call   8005d3 <close>
	return r;
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	89 f0                	mov    %esi,%eax
}
  8009db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	89 c6                	mov    %eax,%esi
  8009e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009f2:	75 12                	jne    800a06 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f4:	83 ec 0c             	sub    $0xc,%esp
  8009f7:	6a 01                	push   $0x1
  8009f9:	e8 11 16 00 00       	call   80200f <ipc_find_env>
  8009fe:	a3 00 40 80 00       	mov    %eax,0x804000
  800a03:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a06:	6a 07                	push   $0x7
  800a08:	68 00 50 80 00       	push   $0x805000
  800a0d:	56                   	push   %esi
  800a0e:	ff 35 00 40 80 00    	pushl  0x804000
  800a14:	e8 a2 15 00 00       	call   801fbb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a19:	83 c4 0c             	add    $0xc,%esp
  800a1c:	6a 00                	push   $0x0
  800a1e:	53                   	push   %ebx
  800a1f:	6a 00                	push   $0x0
  800a21:	e8 2c 15 00 00       	call   801f52 <ipc_recv>
}
  800a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800a50:	e8 8d ff ff ff       	call   8009e2 <fsipc>
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 40 0c             	mov    0xc(%eax),%eax
  800a63:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800a72:	e8 6b ff ff ff       	call   8009e2 <fsipc>
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 04             	sub    $0x4,%esp
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 40 0c             	mov    0xc(%eax),%eax
  800a89:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	b8 05 00 00 00       	mov    $0x5,%eax
  800a98:	e8 45 ff ff ff       	call   8009e2 <fsipc>
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	78 2c                	js     800acd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aa1:	83 ec 08             	sub    $0x8,%esp
  800aa4:	68 00 50 80 00       	push   $0x805000
  800aa9:	53                   	push   %ebx
  800aaa:	e8 5c 11 00 00       	call   801c0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aaf:	a1 80 50 80 00       	mov    0x805080,%eax
  800ab4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aba:	a1 84 50 80 00       	mov    0x805084,%eax
  800abf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	53                   	push   %ebx
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	8b 52 0c             	mov    0xc(%edx),%edx
  800ae2:	89 15 00 50 80 00    	mov    %edx,0x805000
  800ae8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800aed:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800af2:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800af5:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800afb:	53                   	push   %ebx
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	68 08 50 80 00       	push   $0x805008
  800b04:	e8 94 12 00 00       	call   801d9d <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b13:	e8 ca fe ff ff       	call   8009e2 <fsipc>
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	78 1d                	js     800b3c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800b1f:	39 d8                	cmp    %ebx,%eax
  800b21:	76 19                	jbe    800b3c <devfile_write+0x6a>
  800b23:	68 e8 23 80 00       	push   $0x8023e8
  800b28:	68 f4 23 80 00       	push   $0x8023f4
  800b2d:	68 a5 00 00 00       	push   $0xa5
  800b32:	68 09 24 80 00       	push   $0x802409
  800b37:	e8 71 0a 00 00       	call   8015ad <_panic>
	return r;
}
  800b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b4f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b54:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	e8 79 fe ff ff       	call   8009e2 <fsipc>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	78 4b                	js     800bba <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b6f:	39 c6                	cmp    %eax,%esi
  800b71:	73 16                	jae    800b89 <devfile_read+0x48>
  800b73:	68 14 24 80 00       	push   $0x802414
  800b78:	68 f4 23 80 00       	push   $0x8023f4
  800b7d:	6a 7c                	push   $0x7c
  800b7f:	68 09 24 80 00       	push   $0x802409
  800b84:	e8 24 0a 00 00       	call   8015ad <_panic>
	assert(r <= PGSIZE);
  800b89:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b8e:	7e 16                	jle    800ba6 <devfile_read+0x65>
  800b90:	68 1b 24 80 00       	push   $0x80241b
  800b95:	68 f4 23 80 00       	push   $0x8023f4
  800b9a:	6a 7d                	push   $0x7d
  800b9c:	68 09 24 80 00       	push   $0x802409
  800ba1:	e8 07 0a 00 00       	call   8015ad <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ba6:	83 ec 04             	sub    $0x4,%esp
  800ba9:	50                   	push   %eax
  800baa:	68 00 50 80 00       	push   $0x805000
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	e8 e6 11 00 00       	call   801d9d <memmove>
	return r;
  800bb7:	83 c4 10             	add    $0x10,%esp
}
  800bba:	89 d8                	mov    %ebx,%eax
  800bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 20             	sub    $0x20,%esp
  800bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bcd:	53                   	push   %ebx
  800bce:	e8 ff 0f 00 00       	call   801bd2 <strlen>
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bdb:	7f 67                	jg     800c44 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be3:	50                   	push   %eax
  800be4:	e8 71 f8 ff ff       	call   80045a <fd_alloc>
  800be9:	83 c4 10             	add    $0x10,%esp
		return r;
  800bec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	78 57                	js     800c49 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bf2:	83 ec 08             	sub    $0x8,%esp
  800bf5:	53                   	push   %ebx
  800bf6:	68 00 50 80 00       	push   $0x805000
  800bfb:	e8 0b 10 00 00       	call   801c0b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c03:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c10:	e8 cd fd ff ff       	call   8009e2 <fsipc>
  800c15:	89 c3                	mov    %eax,%ebx
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	79 14                	jns    800c32 <open+0x6f>
		fd_close(fd, 0);
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	6a 00                	push   $0x0
  800c23:	ff 75 f4             	pushl  -0xc(%ebp)
  800c26:	e8 27 f9 ff ff       	call   800552 <fd_close>
		return r;
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	89 da                	mov    %ebx,%edx
  800c30:	eb 17                	jmp    800c49 <open+0x86>
	}

	return fd2num(fd);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	ff 75 f4             	pushl  -0xc(%ebp)
  800c38:	e8 f6 f7 ff ff       	call   800433 <fd2num>
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	eb 05                	jmp    800c49 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c44:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c49:	89 d0                	mov    %edx,%eax
  800c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c56:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c60:	e8 7d fd ff ff       	call   8009e2 <fsipc>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c6d:	68 27 24 80 00       	push   $0x802427
  800c72:	ff 75 0c             	pushl  0xc(%ebp)
  800c75:	e8 91 0f 00 00       	call   801c0b <strcpy>
	return 0;
}
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	53                   	push   %ebx
  800c85:	83 ec 10             	sub    $0x10,%esp
  800c88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c8b:	53                   	push   %ebx
  800c8c:	e8 b7 13 00 00       	call   802048 <pageref>
  800c91:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c99:	83 f8 01             	cmp    $0x1,%eax
  800c9c:	75 10                	jne    800cae <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	ff 73 0c             	pushl  0xc(%ebx)
  800ca4:	e8 c0 02 00 00       	call   800f69 <nsipc_close>
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800cae:	89 d0                	mov    %edx,%eax
  800cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 10             	pushl  0x10(%ebp)
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	ff 70 0c             	pushl  0xc(%eax)
  800cc9:	e8 78 03 00 00       	call   801046 <nsipc_send>
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800cd6:	6a 00                	push   $0x0
  800cd8:	ff 75 10             	pushl  0x10(%ebp)
  800cdb:	ff 75 0c             	pushl  0xc(%ebp)
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	ff 70 0c             	pushl  0xc(%eax)
  800ce4:	e8 f1 02 00 00       	call   800fda <nsipc_recv>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cf1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cf4:	52                   	push   %edx
  800cf5:	50                   	push   %eax
  800cf6:	e8 ae f7 ff ff       	call   8004a9 <fd_lookup>
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	78 17                	js     800d19 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d05:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800d0b:	39 08                	cmp    %ecx,(%eax)
  800d0d:	75 05                	jne    800d14 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800d0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800d12:	eb 05                	jmp    800d19 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800d14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 1c             	sub    $0x1c,%esp
  800d23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d28:	50                   	push   %eax
  800d29:	e8 2c f7 ff ff       	call   80045a <fd_alloc>
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 1b                	js     800d52 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d37:	83 ec 04             	sub    $0x4,%esp
  800d3a:	68 07 04 00 00       	push   $0x407
  800d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d42:	6a 00                	push   $0x0
  800d44:	e8 15 f4 ff ff       	call   80015e <sys_page_alloc>
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	79 10                	jns    800d62 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	56                   	push   %esi
  800d56:	e8 0e 02 00 00       	call   800f69 <nsipc_close>
		return r;
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	eb 24                	jmp    800d86 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d62:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d70:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d77:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	50                   	push   %eax
  800d7e:	e8 b0 f6 ff ff       	call   800433 <fd2num>
  800d83:	83 c4 10             	add    $0x10,%esp
}
  800d86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	e8 50 ff ff ff       	call   800ceb <fd2sockid>
		return r;
  800d9b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	78 1f                	js     800dc0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	ff 75 10             	pushl  0x10(%ebp)
  800da7:	ff 75 0c             	pushl  0xc(%ebp)
  800daa:	50                   	push   %eax
  800dab:	e8 12 01 00 00       	call   800ec2 <nsipc_accept>
  800db0:	83 c4 10             	add    $0x10,%esp
		return r;
  800db3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	78 07                	js     800dc0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800db9:	e8 5d ff ff ff       	call   800d1b <alloc_sockfd>
  800dbe:	89 c1                	mov    %eax,%ecx
}
  800dc0:	89 c8                	mov    %ecx,%eax
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	e8 19 ff ff ff       	call   800ceb <fd2sockid>
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 12                	js     800de8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	ff 75 10             	pushl  0x10(%ebp)
  800ddc:	ff 75 0c             	pushl  0xc(%ebp)
  800ddf:	50                   	push   %eax
  800de0:	e8 2d 01 00 00       	call   800f12 <nsipc_bind>
  800de5:	83 c4 10             	add    $0x10,%esp
}
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <shutdown>:

int
shutdown(int s, int how)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	e8 f3 fe ff ff       	call   800ceb <fd2sockid>
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 0f                	js     800e0b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	ff 75 0c             	pushl  0xc(%ebp)
  800e02:	50                   	push   %eax
  800e03:	e8 3f 01 00 00       	call   800f47 <nsipc_shutdown>
  800e08:	83 c4 10             	add    $0x10,%esp
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	e8 d0 fe ff ff       	call   800ceb <fd2sockid>
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	78 12                	js     800e31 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	ff 75 10             	pushl  0x10(%ebp)
  800e25:	ff 75 0c             	pushl  0xc(%ebp)
  800e28:	50                   	push   %eax
  800e29:	e8 55 01 00 00       	call   800f83 <nsipc_connect>
  800e2e:	83 c4 10             	add    $0x10,%esp
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <listen>:

int
listen(int s, int backlog)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	e8 aa fe ff ff       	call   800ceb <fd2sockid>
  800e41:	85 c0                	test   %eax,%eax
  800e43:	78 0f                	js     800e54 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	ff 75 0c             	pushl  0xc(%ebp)
  800e4b:	50                   	push   %eax
  800e4c:	e8 67 01 00 00       	call   800fb8 <nsipc_listen>
  800e51:	83 c4 10             	add    $0x10,%esp
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e5c:	ff 75 10             	pushl  0x10(%ebp)
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	ff 75 08             	pushl  0x8(%ebp)
  800e65:	e8 3a 02 00 00       	call   8010a4 <nsipc_socket>
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 05                	js     800e76 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e71:	e8 a5 fe ff ff       	call   800d1b <alloc_sockfd>
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e81:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e88:	75 12                	jne    800e9c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	6a 02                	push   $0x2
  800e8f:	e8 7b 11 00 00       	call   80200f <ipc_find_env>
  800e94:	a3 04 40 80 00       	mov    %eax,0x804004
  800e99:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e9c:	6a 07                	push   $0x7
  800e9e:	68 00 60 80 00       	push   $0x806000
  800ea3:	53                   	push   %ebx
  800ea4:	ff 35 04 40 80 00    	pushl  0x804004
  800eaa:	e8 0c 11 00 00       	call   801fbb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800eaf:	83 c4 0c             	add    $0xc,%esp
  800eb2:	6a 00                	push   $0x0
  800eb4:	6a 00                	push   $0x0
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 95 10 00 00       	call   801f52 <ipc_recv>
}
  800ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ed2:	8b 06                	mov    (%esi),%eax
  800ed4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ed9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ede:	e8 95 ff ff ff       	call   800e78 <nsipc>
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 20                	js     800f09 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	ff 35 10 60 80 00    	pushl  0x806010
  800ef2:	68 00 60 80 00       	push   $0x806000
  800ef7:	ff 75 0c             	pushl  0xc(%ebp)
  800efa:	e8 9e 0e 00 00       	call   801d9d <memmove>
		*addrlen = ret->ret_addrlen;
  800eff:	a1 10 60 80 00       	mov    0x806010,%eax
  800f04:	89 06                	mov    %eax,(%esi)
  800f06:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	53                   	push   %ebx
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f24:	53                   	push   %ebx
  800f25:	ff 75 0c             	pushl  0xc(%ebp)
  800f28:	68 04 60 80 00       	push   $0x806004
  800f2d:	e8 6b 0e 00 00       	call   801d9d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f32:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f38:	b8 02 00 00 00       	mov    $0x2,%eax
  800f3d:	e8 36 ff ff ff       	call   800e78 <nsipc>
}
  800f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f58:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f62:	e8 11 ff ff ff       	call   800e78 <nsipc>
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <nsipc_close>:

int
nsipc_close(int s)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f77:	b8 04 00 00 00       	mov    $0x4,%eax
  800f7c:	e8 f7 fe ff ff       	call   800e78 <nsipc>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f95:	53                   	push   %ebx
  800f96:	ff 75 0c             	pushl  0xc(%ebp)
  800f99:	68 04 60 80 00       	push   $0x806004
  800f9e:	e8 fa 0d 00 00       	call   801d9d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800fa3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800fa9:	b8 05 00 00 00       	mov    $0x5,%eax
  800fae:	e8 c5 fe ff ff       	call   800e78 <nsipc>
}
  800fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fce:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd3:	e8 a0 fe ff ff       	call   800e78 <nsipc>
}
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    

00800fda <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fea:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800ff0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800ff8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffd:	e8 76 fe ff ff       	call   800e78 <nsipc>
  801002:	89 c3                	mov    %eax,%ebx
  801004:	85 c0                	test   %eax,%eax
  801006:	78 35                	js     80103d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801008:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80100d:	7f 04                	jg     801013 <nsipc_recv+0x39>
  80100f:	39 c6                	cmp    %eax,%esi
  801011:	7d 16                	jge    801029 <nsipc_recv+0x4f>
  801013:	68 33 24 80 00       	push   $0x802433
  801018:	68 f4 23 80 00       	push   $0x8023f4
  80101d:	6a 62                	push   $0x62
  80101f:	68 48 24 80 00       	push   $0x802448
  801024:	e8 84 05 00 00       	call   8015ad <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	50                   	push   %eax
  80102d:	68 00 60 80 00       	push   $0x806000
  801032:	ff 75 0c             	pushl  0xc(%ebp)
  801035:	e8 63 0d 00 00       	call   801d9d <memmove>
  80103a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	53                   	push   %ebx
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801058:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80105e:	7e 16                	jle    801076 <nsipc_send+0x30>
  801060:	68 54 24 80 00       	push   $0x802454
  801065:	68 f4 23 80 00       	push   $0x8023f4
  80106a:	6a 6d                	push   $0x6d
  80106c:	68 48 24 80 00       	push   $0x802448
  801071:	e8 37 05 00 00       	call   8015ad <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	53                   	push   %ebx
  80107a:	ff 75 0c             	pushl  0xc(%ebp)
  80107d:	68 0c 60 80 00       	push   $0x80600c
  801082:	e8 16 0d 00 00       	call   801d9d <memmove>
	nsipcbuf.send.req_size = size;
  801087:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80108d:	8b 45 14             	mov    0x14(%ebp),%eax
  801090:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801095:	b8 08 00 00 00       	mov    $0x8,%eax
  80109a:	e8 d9 fd ff ff       	call   800e78 <nsipc>
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c7:	e8 ac fd ff ff       	call   800e78 <nsipc>
}
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	ff 75 08             	pushl  0x8(%ebp)
  8010dc:	e8 62 f3 ff ff       	call   800443 <fd2data>
  8010e1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010e3:	83 c4 08             	add    $0x8,%esp
  8010e6:	68 60 24 80 00       	push   $0x802460
  8010eb:	53                   	push   %ebx
  8010ec:	e8 1a 0b 00 00       	call   801c0b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010f1:	8b 46 04             	mov    0x4(%esi),%eax
  8010f4:	2b 06                	sub    (%esi),%eax
  8010f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801103:	00 00 00 
	stat->st_dev = &devpipe;
  801106:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80110d:	30 80 00 
	return 0;
}
  801110:	b8 00 00 00 00       	mov    $0x0,%eax
  801115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801118:	5b                   	pop    %ebx
  801119:	5e                   	pop    %esi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801126:	53                   	push   %ebx
  801127:	6a 00                	push   $0x0
  801129:	e8 b5 f0 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80112e:	89 1c 24             	mov    %ebx,(%esp)
  801131:	e8 0d f3 ff ff       	call   800443 <fd2data>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	50                   	push   %eax
  80113a:	6a 00                	push   $0x0
  80113c:	e8 a2 f0 ff ff       	call   8001e3 <sys_page_unmap>
}
  801141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 1c             	sub    $0x1c,%esp
  80114f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801152:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801154:	a1 08 40 80 00       	mov    0x804008,%eax
  801159:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 e0             	pushl  -0x20(%ebp)
  801162:	e8 e1 0e 00 00       	call   802048 <pageref>
  801167:	89 c3                	mov    %eax,%ebx
  801169:	89 3c 24             	mov    %edi,(%esp)
  80116c:	e8 d7 0e 00 00       	call   802048 <pageref>
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	39 c3                	cmp    %eax,%ebx
  801176:	0f 94 c1             	sete   %cl
  801179:	0f b6 c9             	movzbl %cl,%ecx
  80117c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80117f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801185:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801188:	39 ce                	cmp    %ecx,%esi
  80118a:	74 1b                	je     8011a7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80118c:	39 c3                	cmp    %eax,%ebx
  80118e:	75 c4                	jne    801154 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801190:	8b 42 58             	mov    0x58(%edx),%eax
  801193:	ff 75 e4             	pushl  -0x1c(%ebp)
  801196:	50                   	push   %eax
  801197:	56                   	push   %esi
  801198:	68 67 24 80 00       	push   $0x802467
  80119d:	e8 e4 04 00 00       	call   801686 <cprintf>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb ad                	jmp    801154 <_pipeisclosed+0xe>
	}
}
  8011a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 28             	sub    $0x28,%esp
  8011bb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011be:	56                   	push   %esi
  8011bf:	e8 7f f2 ff ff       	call   800443 <fd2data>
  8011c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ce:	eb 4b                	jmp    80121b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011d0:	89 da                	mov    %ebx,%edx
  8011d2:	89 f0                	mov    %esi,%eax
  8011d4:	e8 6d ff ff ff       	call   801146 <_pipeisclosed>
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 48                	jne    801225 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011dd:	e8 5d ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011e5:	8b 0b                	mov    (%ebx),%ecx
  8011e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8011ea:	39 d0                	cmp    %edx,%eax
  8011ec:	73 e2                	jae    8011d0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011f5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 fa 1f             	sar    $0x1f,%edx
  8011fd:	89 d1                	mov    %edx,%ecx
  8011ff:	c1 e9 1b             	shr    $0x1b,%ecx
  801202:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801205:	83 e2 1f             	and    $0x1f,%edx
  801208:	29 ca                	sub    %ecx,%edx
  80120a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80120e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801212:	83 c0 01             	add    $0x1,%eax
  801215:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801218:	83 c7 01             	add    $0x1,%edi
  80121b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80121e:	75 c2                	jne    8011e2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801220:	8b 45 10             	mov    0x10(%ebp),%eax
  801223:	eb 05                	jmp    80122a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80122a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 18             	sub    $0x18,%esp
  80123b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80123e:	57                   	push   %edi
  80123f:	e8 ff f1 ff ff       	call   800443 <fd2data>
  801244:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124e:	eb 3d                	jmp    80128d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801250:	85 db                	test   %ebx,%ebx
  801252:	74 04                	je     801258 <devpipe_read+0x26>
				return i;
  801254:	89 d8                	mov    %ebx,%eax
  801256:	eb 44                	jmp    80129c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801258:	89 f2                	mov    %esi,%edx
  80125a:	89 f8                	mov    %edi,%eax
  80125c:	e8 e5 fe ff ff       	call   801146 <_pipeisclosed>
  801261:	85 c0                	test   %eax,%eax
  801263:	75 32                	jne    801297 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801265:	e8 d5 ee ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80126a:	8b 06                	mov    (%esi),%eax
  80126c:	3b 46 04             	cmp    0x4(%esi),%eax
  80126f:	74 df                	je     801250 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801271:	99                   	cltd   
  801272:	c1 ea 1b             	shr    $0x1b,%edx
  801275:	01 d0                	add    %edx,%eax
  801277:	83 e0 1f             	and    $0x1f,%eax
  80127a:	29 d0                	sub    %edx,%eax
  80127c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801284:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801287:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80128a:	83 c3 01             	add    $0x1,%ebx
  80128d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801290:	75 d8                	jne    80126a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801292:	8b 45 10             	mov    0x10(%ebp),%eax
  801295:	eb 05                	jmp    80129c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80129c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	e8 a5 f1 ff ff       	call   80045a <fd_alloc>
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	0f 88 2c 01 00 00    	js     8013ee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	68 07 04 00 00       	push   $0x407
  8012ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cd:	6a 00                	push   $0x0
  8012cf:	e8 8a ee ff ff       	call   80015e <sys_page_alloc>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	0f 88 0d 01 00 00    	js     8013ee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	e8 6d f1 ff ff       	call   80045a <fd_alloc>
  8012ed:	89 c3                	mov    %eax,%ebx
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	0f 88 e2 00 00 00    	js     8013dc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012fa:	83 ec 04             	sub    $0x4,%esp
  8012fd:	68 07 04 00 00       	push   $0x407
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	6a 00                	push   $0x0
  801307:	e8 52 ee ff ff       	call   80015e <sys_page_alloc>
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	0f 88 c3 00 00 00    	js     8013dc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	ff 75 f4             	pushl  -0xc(%ebp)
  80131f:	e8 1f f1 ff ff       	call   800443 <fd2data>
  801324:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801326:	83 c4 0c             	add    $0xc,%esp
  801329:	68 07 04 00 00       	push   $0x407
  80132e:	50                   	push   %eax
  80132f:	6a 00                	push   $0x0
  801331:	e8 28 ee ff ff       	call   80015e <sys_page_alloc>
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	0f 88 89 00 00 00    	js     8013cc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	ff 75 f0             	pushl  -0x10(%ebp)
  801349:	e8 f5 f0 ff ff       	call   800443 <fd2data>
  80134e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801355:	50                   	push   %eax
  801356:	6a 00                	push   $0x0
  801358:	56                   	push   %esi
  801359:	6a 00                	push   $0x0
  80135b:	e8 41 ee ff ff       	call   8001a1 <sys_page_map>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 20             	add    $0x20,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 55                	js     8013be <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801369:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801377:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80137e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801384:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801387:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	ff 75 f4             	pushl  -0xc(%ebp)
  801399:	e8 95 f0 ff ff       	call   800433 <fd2num>
  80139e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013a3:	83 c4 04             	add    $0x4,%esp
  8013a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a9:	e8 85 f0 ff ff       	call   800433 <fd2num>
  8013ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	eb 30                	jmp    8013ee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	56                   	push   %esi
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 1a ee ff ff       	call   8001e3 <sys_page_unmap>
  8013c9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 0a ee ff ff       	call   8001e3 <sys_page_unmap>
  8013d9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e2:	6a 00                	push   $0x0
  8013e4:	e8 fa ed ff ff       	call   8001e3 <sys_page_unmap>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013ee:	89 d0                	mov    %edx,%eax
  8013f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	ff 75 08             	pushl  0x8(%ebp)
  801404:	e8 a0 f0 ff ff       	call   8004a9 <fd_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 18                	js     801428 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	ff 75 f4             	pushl  -0xc(%ebp)
  801416:	e8 28 f0 ff ff       	call   800443 <fd2data>
	return _pipeisclosed(fd, p);
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801420:	e8 21 fd ff ff       	call   801146 <_pipeisclosed>
  801425:	83 c4 10             	add    $0x10,%esp
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80142d:	b8 00 00 00 00       	mov    $0x0,%eax
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80143a:	68 7f 24 80 00       	push   $0x80247f
  80143f:	ff 75 0c             	pushl  0xc(%ebp)
  801442:	e8 c4 07 00 00       	call   801c0b <strcpy>
	return 0;
}
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	53                   	push   %ebx
  801454:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80145a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80145f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801465:	eb 2d                	jmp    801494 <devcons_write+0x46>
		m = n - tot;
  801467:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80146a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80146c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80146f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801474:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	53                   	push   %ebx
  80147b:	03 45 0c             	add    0xc(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	57                   	push   %edi
  801480:	e8 18 09 00 00       	call   801d9d <memmove>
		sys_cputs(buf, m);
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	53                   	push   %ebx
  801489:	57                   	push   %edi
  80148a:	e8 13 ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148f:	01 de                	add    %ebx,%esi
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 f0                	mov    %esi,%eax
  801496:	3b 75 10             	cmp    0x10(%ebp),%esi
  801499:	72 cc                	jb     801467 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80149b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014b2:	74 2a                	je     8014de <devcons_read+0x3b>
  8014b4:	eb 05                	jmp    8014bb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014b6:	e8 84 ec ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014bb:	e8 00 ec ff ff       	call   8000c0 <sys_cgetc>
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	74 f2                	je     8014b6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 16                	js     8014de <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014c8:	83 f8 04             	cmp    $0x4,%eax
  8014cb:	74 0c                	je     8014d9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d0:	88 02                	mov    %al,(%edx)
	return 1;
  8014d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d7:	eb 05                	jmp    8014de <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014ec:	6a 01                	push   $0x1
  8014ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	e8 ab eb ff ff       	call   8000a2 <sys_cputs>
}
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <getchar>:

int
getchar(void)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801502:	6a 01                	push   $0x1
  801504:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	6a 00                	push   $0x0
  80150a:	e8 00 f2 ff ff       	call   80070f <read>
	if (r < 0)
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 0f                	js     801525 <getchar+0x29>
		return r;
	if (r < 1)
  801516:	85 c0                	test   %eax,%eax
  801518:	7e 06                	jle    801520 <getchar+0x24>
		return -E_EOF;
	return c;
  80151a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80151e:	eb 05                	jmp    801525 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801520:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	ff 75 08             	pushl  0x8(%ebp)
  801534:	e8 70 ef ff ff       	call   8004a9 <fd_lookup>
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 11                	js     801551 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801549:	39 10                	cmp    %edx,(%eax)
  80154b:	0f 94 c0             	sete   %al
  80154e:	0f b6 c0             	movzbl %al,%eax
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <opencons>:

int
opencons(void)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	e8 f8 ee ff ff       	call   80045a <fd_alloc>
  801562:	83 c4 10             	add    $0x10,%esp
		return r;
  801565:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801567:	85 c0                	test   %eax,%eax
  801569:	78 3e                	js     8015a9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	68 07 04 00 00       	push   $0x407
  801573:	ff 75 f4             	pushl  -0xc(%ebp)
  801576:	6a 00                	push   $0x0
  801578:	e8 e1 eb ff ff       	call   80015e <sys_page_alloc>
  80157d:	83 c4 10             	add    $0x10,%esp
		return r;
  801580:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801582:	85 c0                	test   %eax,%eax
  801584:	78 23                	js     8015a9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801586:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801591:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801594:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	50                   	push   %eax
  80159f:	e8 8f ee ff ff       	call   800433 <fd2num>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	83 c4 10             	add    $0x10,%esp
}
  8015a9:	89 d0                	mov    %edx,%eax
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015b2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015b5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015bb:	e8 60 eb ff ff       	call   800120 <sys_getenvid>
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	ff 75 0c             	pushl  0xc(%ebp)
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	56                   	push   %esi
  8015ca:	50                   	push   %eax
  8015cb:	68 8c 24 80 00       	push   $0x80248c
  8015d0:	e8 b1 00 00 00       	call   801686 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015d5:	83 c4 18             	add    $0x18,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	ff 75 10             	pushl  0x10(%ebp)
  8015dc:	e8 54 00 00 00       	call   801635 <vcprintf>
	cprintf("\n");
  8015e1:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  8015e8:	e8 99 00 00 00       	call   801686 <cprintf>
  8015ed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015f0:	cc                   	int3   
  8015f1:	eb fd                	jmp    8015f0 <_panic+0x43>

008015f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015fd:	8b 13                	mov    (%ebx),%edx
  8015ff:	8d 42 01             	lea    0x1(%edx),%eax
  801602:	89 03                	mov    %eax,(%ebx)
  801604:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801607:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80160b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801610:	75 1a                	jne    80162c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	68 ff 00 00 00       	push   $0xff
  80161a:	8d 43 08             	lea    0x8(%ebx),%eax
  80161d:	50                   	push   %eax
  80161e:	e8 7f ea ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801623:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801629:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80162c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80163e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801645:	00 00 00 
	b.cnt = 0;
  801648:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80164f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	68 f3 15 80 00       	push   $0x8015f3
  801664:	e8 54 01 00 00       	call   8017bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801672:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	e8 24 ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80167e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80168c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80168f:	50                   	push   %eax
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 9d ff ff ff       	call   801635 <vcprintf>
	va_end(ap);

	return cnt;
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 1c             	sub    $0x1c,%esp
  8016a3:	89 c7                	mov    %eax,%edi
  8016a5:	89 d6                	mov    %edx,%esi
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016be:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016c1:	39 d3                	cmp    %edx,%ebx
  8016c3:	72 05                	jb     8016ca <printnum+0x30>
  8016c5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016c8:	77 45                	ja     80170f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	ff 75 18             	pushl  0x18(%ebp)
  8016d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016d6:	53                   	push   %ebx
  8016d7:	ff 75 10             	pushl  0x10(%ebp)
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e9:	e8 a2 09 00 00       	call   802090 <__udivdi3>
  8016ee:	83 c4 18             	add    $0x18,%esp
  8016f1:	52                   	push   %edx
  8016f2:	50                   	push   %eax
  8016f3:	89 f2                	mov    %esi,%edx
  8016f5:	89 f8                	mov    %edi,%eax
  8016f7:	e8 9e ff ff ff       	call   80169a <printnum>
  8016fc:	83 c4 20             	add    $0x20,%esp
  8016ff:	eb 18                	jmp    801719 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	56                   	push   %esi
  801705:	ff 75 18             	pushl  0x18(%ebp)
  801708:	ff d7                	call   *%edi
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	eb 03                	jmp    801712 <printnum+0x78>
  80170f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801712:	83 eb 01             	sub    $0x1,%ebx
  801715:	85 db                	test   %ebx,%ebx
  801717:	7f e8                	jg     801701 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	56                   	push   %esi
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	ff 75 e4             	pushl  -0x1c(%ebp)
  801723:	ff 75 e0             	pushl  -0x20(%ebp)
  801726:	ff 75 dc             	pushl  -0x24(%ebp)
  801729:	ff 75 d8             	pushl  -0x28(%ebp)
  80172c:	e8 8f 0a 00 00       	call   8021c0 <__umoddi3>
  801731:	83 c4 14             	add    $0x14,%esp
  801734:	0f be 80 af 24 80 00 	movsbl 0x8024af(%eax),%eax
  80173b:	50                   	push   %eax
  80173c:	ff d7                	call   *%edi
}
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801744:	5b                   	pop    %ebx
  801745:	5e                   	pop    %esi
  801746:	5f                   	pop    %edi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80174c:	83 fa 01             	cmp    $0x1,%edx
  80174f:	7e 0e                	jle    80175f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801751:	8b 10                	mov    (%eax),%edx
  801753:	8d 4a 08             	lea    0x8(%edx),%ecx
  801756:	89 08                	mov    %ecx,(%eax)
  801758:	8b 02                	mov    (%edx),%eax
  80175a:	8b 52 04             	mov    0x4(%edx),%edx
  80175d:	eb 22                	jmp    801781 <getuint+0x38>
	else if (lflag)
  80175f:	85 d2                	test   %edx,%edx
  801761:	74 10                	je     801773 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801763:	8b 10                	mov    (%eax),%edx
  801765:	8d 4a 04             	lea    0x4(%edx),%ecx
  801768:	89 08                	mov    %ecx,(%eax)
  80176a:	8b 02                	mov    (%edx),%eax
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	eb 0e                	jmp    801781 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801773:	8b 10                	mov    (%eax),%edx
  801775:	8d 4a 04             	lea    0x4(%edx),%ecx
  801778:	89 08                	mov    %ecx,(%eax)
  80177a:	8b 02                	mov    (%edx),%eax
  80177c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801789:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80178d:	8b 10                	mov    (%eax),%edx
  80178f:	3b 50 04             	cmp    0x4(%eax),%edx
  801792:	73 0a                	jae    80179e <sprintputch+0x1b>
		*b->buf++ = ch;
  801794:	8d 4a 01             	lea    0x1(%edx),%ecx
  801797:	89 08                	mov    %ecx,(%eax)
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	88 02                	mov    %al,(%edx)
}
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017a9:	50                   	push   %eax
  8017aa:	ff 75 10             	pushl  0x10(%ebp)
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	ff 75 08             	pushl  0x8(%ebp)
  8017b3:	e8 05 00 00 00       	call   8017bd <vprintfmt>
	va_end(ap);
}
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	57                   	push   %edi
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 2c             	sub    $0x2c,%esp
  8017c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017cf:	eb 12                	jmp    8017e3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	0f 84 89 03 00 00    	je     801b62 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	53                   	push   %ebx
  8017dd:	50                   	push   %eax
  8017de:	ff d6                	call   *%esi
  8017e0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017e3:	83 c7 01             	add    $0x1,%edi
  8017e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ea:	83 f8 25             	cmp    $0x25,%eax
  8017ed:	75 e2                	jne    8017d1 <vprintfmt+0x14>
  8017ef:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801801:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	eb 07                	jmp    801816 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801812:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801816:	8d 47 01             	lea    0x1(%edi),%eax
  801819:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80181c:	0f b6 07             	movzbl (%edi),%eax
  80181f:	0f b6 c8             	movzbl %al,%ecx
  801822:	83 e8 23             	sub    $0x23,%eax
  801825:	3c 55                	cmp    $0x55,%al
  801827:	0f 87 1a 03 00 00    	ja     801b47 <vprintfmt+0x38a>
  80182d:	0f b6 c0             	movzbl %al,%eax
  801830:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  801837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80183a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80183e:	eb d6                	jmp    801816 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801840:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
  801848:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80184b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80184e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801852:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801855:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801858:	83 fa 09             	cmp    $0x9,%edx
  80185b:	77 39                	ja     801896 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80185d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801860:	eb e9                	jmp    80184b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801862:	8b 45 14             	mov    0x14(%ebp),%eax
  801865:	8d 48 04             	lea    0x4(%eax),%ecx
  801868:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80186b:	8b 00                	mov    (%eax),%eax
  80186d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801870:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801873:	eb 27                	jmp    80189c <vprintfmt+0xdf>
  801875:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801878:	85 c0                	test   %eax,%eax
  80187a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80187f:	0f 49 c8             	cmovns %eax,%ecx
  801882:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801888:	eb 8c                	jmp    801816 <vprintfmt+0x59>
  80188a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80188d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801894:	eb 80                	jmp    801816 <vprintfmt+0x59>
  801896:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801899:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80189c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018a0:	0f 89 70 ff ff ff    	jns    801816 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018b3:	e9 5e ff ff ff       	jmp    801816 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018b8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018be:	e9 53 ff ff ff       	jmp    801816 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c6:	8d 50 04             	lea    0x4(%eax),%edx
  8018c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	ff 30                	pushl  (%eax)
  8018d2:	ff d6                	call   *%esi
			break;
  8018d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018da:	e9 04 ff ff ff       	jmp    8017e3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018df:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e2:	8d 50 04             	lea    0x4(%eax),%edx
  8018e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e8:	8b 00                	mov    (%eax),%eax
  8018ea:	99                   	cltd   
  8018eb:	31 d0                	xor    %edx,%eax
  8018ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018ef:	83 f8 0f             	cmp    $0xf,%eax
  8018f2:	7f 0b                	jg     8018ff <vprintfmt+0x142>
  8018f4:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8018fb:	85 d2                	test   %edx,%edx
  8018fd:	75 18                	jne    801917 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018ff:	50                   	push   %eax
  801900:	68 c7 24 80 00       	push   $0x8024c7
  801905:	53                   	push   %ebx
  801906:	56                   	push   %esi
  801907:	e8 94 fe ff ff       	call   8017a0 <printfmt>
  80190c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801912:	e9 cc fe ff ff       	jmp    8017e3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801917:	52                   	push   %edx
  801918:	68 06 24 80 00       	push   $0x802406
  80191d:	53                   	push   %ebx
  80191e:	56                   	push   %esi
  80191f:	e8 7c fe ff ff       	call   8017a0 <printfmt>
  801924:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801927:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80192a:	e9 b4 fe ff ff       	jmp    8017e3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80192f:	8b 45 14             	mov    0x14(%ebp),%eax
  801932:	8d 50 04             	lea    0x4(%eax),%edx
  801935:	89 55 14             	mov    %edx,0x14(%ebp)
  801938:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80193a:	85 ff                	test   %edi,%edi
  80193c:	b8 c0 24 80 00       	mov    $0x8024c0,%eax
  801941:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801944:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801948:	0f 8e 94 00 00 00    	jle    8019e2 <vprintfmt+0x225>
  80194e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801952:	0f 84 98 00 00 00    	je     8019f0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	ff 75 d0             	pushl  -0x30(%ebp)
  80195e:	57                   	push   %edi
  80195f:	e8 86 02 00 00       	call   801bea <strnlen>
  801964:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801967:	29 c1                	sub    %eax,%ecx
  801969:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80196c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80196f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801973:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801976:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801979:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80197b:	eb 0f                	jmp    80198c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	53                   	push   %ebx
  801981:	ff 75 e0             	pushl  -0x20(%ebp)
  801984:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801986:	83 ef 01             	sub    $0x1,%edi
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 ff                	test   %edi,%edi
  80198e:	7f ed                	jg     80197d <vprintfmt+0x1c0>
  801990:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801993:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801996:	85 c9                	test   %ecx,%ecx
  801998:	b8 00 00 00 00       	mov    $0x0,%eax
  80199d:	0f 49 c1             	cmovns %ecx,%eax
  8019a0:	29 c1                	sub    %eax,%ecx
  8019a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019ab:	89 cb                	mov    %ecx,%ebx
  8019ad:	eb 4d                	jmp    8019fc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019b3:	74 1b                	je     8019d0 <vprintfmt+0x213>
  8019b5:	0f be c0             	movsbl %al,%eax
  8019b8:	83 e8 20             	sub    $0x20,%eax
  8019bb:	83 f8 5e             	cmp    $0x5e,%eax
  8019be:	76 10                	jbe    8019d0 <vprintfmt+0x213>
					putch('?', putdat);
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	6a 3f                	push   $0x3f
  8019c8:	ff 55 08             	call   *0x8(%ebp)
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	eb 0d                	jmp    8019dd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	ff 75 0c             	pushl  0xc(%ebp)
  8019d6:	52                   	push   %edx
  8019d7:	ff 55 08             	call   *0x8(%ebp)
  8019da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019dd:	83 eb 01             	sub    $0x1,%ebx
  8019e0:	eb 1a                	jmp    8019fc <vprintfmt+0x23f>
  8019e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8019e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ee:	eb 0c                	jmp    8019fc <vprintfmt+0x23f>
  8019f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019fc:	83 c7 01             	add    $0x1,%edi
  8019ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a03:	0f be d0             	movsbl %al,%edx
  801a06:	85 d2                	test   %edx,%edx
  801a08:	74 23                	je     801a2d <vprintfmt+0x270>
  801a0a:	85 f6                	test   %esi,%esi
  801a0c:	78 a1                	js     8019af <vprintfmt+0x1f2>
  801a0e:	83 ee 01             	sub    $0x1,%esi
  801a11:	79 9c                	jns    8019af <vprintfmt+0x1f2>
  801a13:	89 df                	mov    %ebx,%edi
  801a15:	8b 75 08             	mov    0x8(%ebp),%esi
  801a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a1b:	eb 18                	jmp    801a35 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	6a 20                	push   $0x20
  801a23:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a25:	83 ef 01             	sub    $0x1,%edi
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	eb 08                	jmp    801a35 <vprintfmt+0x278>
  801a2d:	89 df                	mov    %ebx,%edi
  801a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a35:	85 ff                	test   %edi,%edi
  801a37:	7f e4                	jg     801a1d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a3c:	e9 a2 fd ff ff       	jmp    8017e3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a41:	83 fa 01             	cmp    $0x1,%edx
  801a44:	7e 16                	jle    801a5c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a46:	8b 45 14             	mov    0x14(%ebp),%eax
  801a49:	8d 50 08             	lea    0x8(%eax),%edx
  801a4c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4f:	8b 50 04             	mov    0x4(%eax),%edx
  801a52:	8b 00                	mov    (%eax),%eax
  801a54:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a57:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a5a:	eb 32                	jmp    801a8e <vprintfmt+0x2d1>
	else if (lflag)
  801a5c:	85 d2                	test   %edx,%edx
  801a5e:	74 18                	je     801a78 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8d 50 04             	lea    0x4(%eax),%edx
  801a66:	89 55 14             	mov    %edx,0x14(%ebp)
  801a69:	8b 00                	mov    (%eax),%eax
  801a6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6e:	89 c1                	mov    %eax,%ecx
  801a70:	c1 f9 1f             	sar    $0x1f,%ecx
  801a73:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a76:	eb 16                	jmp    801a8e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a78:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7b:	8d 50 04             	lea    0x4(%eax),%edx
  801a7e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a81:	8b 00                	mov    (%eax),%eax
  801a83:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a86:	89 c1                	mov    %eax,%ecx
  801a88:	c1 f9 1f             	sar    $0x1f,%ecx
  801a8b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a91:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a94:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a99:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a9d:	79 74                	jns    801b13 <vprintfmt+0x356>
				putch('-', putdat);
  801a9f:	83 ec 08             	sub    $0x8,%esp
  801aa2:	53                   	push   %ebx
  801aa3:	6a 2d                	push   $0x2d
  801aa5:	ff d6                	call   *%esi
				num = -(long long) num;
  801aa7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aaa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801aad:	f7 d8                	neg    %eax
  801aaf:	83 d2 00             	adc    $0x0,%edx
  801ab2:	f7 da                	neg    %edx
  801ab4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ab7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801abc:	eb 55                	jmp    801b13 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801abe:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac1:	e8 83 fc ff ff       	call   801749 <getuint>
			base = 10;
  801ac6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801acb:	eb 46                	jmp    801b13 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801acd:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad0:	e8 74 fc ff ff       	call   801749 <getuint>
                        base = 8;
  801ad5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ada:	eb 37                	jmp    801b13 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	53                   	push   %ebx
  801ae0:	6a 30                	push   $0x30
  801ae2:	ff d6                	call   *%esi
			putch('x', putdat);
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	53                   	push   %ebx
  801ae8:	6a 78                	push   $0x78
  801aea:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aec:	8b 45 14             	mov    0x14(%ebp),%eax
  801aef:	8d 50 04             	lea    0x4(%eax),%edx
  801af2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801af5:	8b 00                	mov    (%eax),%eax
  801af7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801afc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801aff:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b04:	eb 0d                	jmp    801b13 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b06:	8d 45 14             	lea    0x14(%ebp),%eax
  801b09:	e8 3b fc ff ff       	call   801749 <getuint>
			base = 16;
  801b0e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b1a:	57                   	push   %edi
  801b1b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1e:	51                   	push   %ecx
  801b1f:	52                   	push   %edx
  801b20:	50                   	push   %eax
  801b21:	89 da                	mov    %ebx,%edx
  801b23:	89 f0                	mov    %esi,%eax
  801b25:	e8 70 fb ff ff       	call   80169a <printnum>
			break;
  801b2a:	83 c4 20             	add    $0x20,%esp
  801b2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b30:	e9 ae fc ff ff       	jmp    8017e3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	53                   	push   %ebx
  801b39:	51                   	push   %ecx
  801b3a:	ff d6                	call   *%esi
			break;
  801b3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b42:	e9 9c fc ff ff       	jmp    8017e3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b47:	83 ec 08             	sub    $0x8,%esp
  801b4a:	53                   	push   %ebx
  801b4b:	6a 25                	push   $0x25
  801b4d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	eb 03                	jmp    801b57 <vprintfmt+0x39a>
  801b54:	83 ef 01             	sub    $0x1,%edi
  801b57:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b5b:	75 f7                	jne    801b54 <vprintfmt+0x397>
  801b5d:	e9 81 fc ff ff       	jmp    8017e3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 18             	sub    $0x18,%esp
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b79:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b7d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b87:	85 c0                	test   %eax,%eax
  801b89:	74 26                	je     801bb1 <vsnprintf+0x47>
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	7e 22                	jle    801bb1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b8f:	ff 75 14             	pushl  0x14(%ebp)
  801b92:	ff 75 10             	pushl  0x10(%ebp)
  801b95:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b98:	50                   	push   %eax
  801b99:	68 83 17 80 00       	push   $0x801783
  801b9e:	e8 1a fc ff ff       	call   8017bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ba6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	eb 05                	jmp    801bb6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bbe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bc1:	50                   	push   %eax
  801bc2:	ff 75 10             	pushl  0x10(%ebp)
  801bc5:	ff 75 0c             	pushl  0xc(%ebp)
  801bc8:	ff 75 08             	pushl  0x8(%ebp)
  801bcb:	e8 9a ff ff ff       	call   801b6a <vsnprintf>
	va_end(ap);

	return rc;
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdd:	eb 03                	jmp    801be2 <strlen+0x10>
		n++;
  801bdf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801be2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801be6:	75 f7                	jne    801bdf <strlen+0xd>
		n++;
	return n;
}
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf8:	eb 03                	jmp    801bfd <strnlen+0x13>
		n++;
  801bfa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bfd:	39 c2                	cmp    %eax,%edx
  801bff:	74 08                	je     801c09 <strnlen+0x1f>
  801c01:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c05:	75 f3                	jne    801bfa <strnlen+0x10>
  801c07:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	83 c2 01             	add    $0x1,%edx
  801c1a:	83 c1 01             	add    $0x1,%ecx
  801c1d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c21:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c24:	84 db                	test   %bl,%bl
  801c26:	75 ef                	jne    801c17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c28:	5b                   	pop    %ebx
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	53                   	push   %ebx
  801c2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c32:	53                   	push   %ebx
  801c33:	e8 9a ff ff ff       	call   801bd2 <strlen>
  801c38:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c3b:	ff 75 0c             	pushl  0xc(%ebp)
  801c3e:	01 d8                	add    %ebx,%eax
  801c40:	50                   	push   %eax
  801c41:	e8 c5 ff ff ff       	call   801c0b <strcpy>
	return dst;
}
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	8b 75 08             	mov    0x8(%ebp),%esi
  801c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c58:	89 f3                	mov    %esi,%ebx
  801c5a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c5d:	89 f2                	mov    %esi,%edx
  801c5f:	eb 0f                	jmp    801c70 <strncpy+0x23>
		*dst++ = *src;
  801c61:	83 c2 01             	add    $0x1,%edx
  801c64:	0f b6 01             	movzbl (%ecx),%eax
  801c67:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c6a:	80 39 01             	cmpb   $0x1,(%ecx)
  801c6d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c70:	39 da                	cmp    %ebx,%edx
  801c72:	75 ed                	jne    801c61 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c74:	89 f0                	mov    %esi,%eax
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c85:	8b 55 10             	mov    0x10(%ebp),%edx
  801c88:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c8a:	85 d2                	test   %edx,%edx
  801c8c:	74 21                	je     801caf <strlcpy+0x35>
  801c8e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	eb 09                	jmp    801c9f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c96:	83 c2 01             	add    $0x1,%edx
  801c99:	83 c1 01             	add    $0x1,%ecx
  801c9c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c9f:	39 c2                	cmp    %eax,%edx
  801ca1:	74 09                	je     801cac <strlcpy+0x32>
  801ca3:	0f b6 19             	movzbl (%ecx),%ebx
  801ca6:	84 db                	test   %bl,%bl
  801ca8:	75 ec                	jne    801c96 <strlcpy+0x1c>
  801caa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801caf:	29 f0                	sub    %esi,%eax
}
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cbe:	eb 06                	jmp    801cc6 <strcmp+0x11>
		p++, q++;
  801cc0:	83 c1 01             	add    $0x1,%ecx
  801cc3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cc6:	0f b6 01             	movzbl (%ecx),%eax
  801cc9:	84 c0                	test   %al,%al
  801ccb:	74 04                	je     801cd1 <strcmp+0x1c>
  801ccd:	3a 02                	cmp    (%edx),%al
  801ccf:	74 ef                	je     801cc0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd1:	0f b6 c0             	movzbl %al,%eax
  801cd4:	0f b6 12             	movzbl (%edx),%edx
  801cd7:	29 d0                	sub    %edx,%eax
}
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	53                   	push   %ebx
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cea:	eb 06                	jmp    801cf2 <strncmp+0x17>
		n--, p++, q++;
  801cec:	83 c0 01             	add    $0x1,%eax
  801cef:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cf2:	39 d8                	cmp    %ebx,%eax
  801cf4:	74 15                	je     801d0b <strncmp+0x30>
  801cf6:	0f b6 08             	movzbl (%eax),%ecx
  801cf9:	84 c9                	test   %cl,%cl
  801cfb:	74 04                	je     801d01 <strncmp+0x26>
  801cfd:	3a 0a                	cmp    (%edx),%cl
  801cff:	74 eb                	je     801cec <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d01:	0f b6 00             	movzbl (%eax),%eax
  801d04:	0f b6 12             	movzbl (%edx),%edx
  801d07:	29 d0                	sub    %edx,%eax
  801d09:	eb 05                	jmp    801d10 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d10:	5b                   	pop    %ebx
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d1d:	eb 07                	jmp    801d26 <strchr+0x13>
		if (*s == c)
  801d1f:	38 ca                	cmp    %cl,%dl
  801d21:	74 0f                	je     801d32 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d23:	83 c0 01             	add    $0x1,%eax
  801d26:	0f b6 10             	movzbl (%eax),%edx
  801d29:	84 d2                	test   %dl,%dl
  801d2b:	75 f2                	jne    801d1f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d3e:	eb 03                	jmp    801d43 <strfind+0xf>
  801d40:	83 c0 01             	add    $0x1,%eax
  801d43:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d46:	38 ca                	cmp    %cl,%dl
  801d48:	74 04                	je     801d4e <strfind+0x1a>
  801d4a:	84 d2                	test   %dl,%dl
  801d4c:	75 f2                	jne    801d40 <strfind+0xc>
			break;
	return (char *) s;
}
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	57                   	push   %edi
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d5c:	85 c9                	test   %ecx,%ecx
  801d5e:	74 36                	je     801d96 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d60:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d66:	75 28                	jne    801d90 <memset+0x40>
  801d68:	f6 c1 03             	test   $0x3,%cl
  801d6b:	75 23                	jne    801d90 <memset+0x40>
		c &= 0xFF;
  801d6d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d71:	89 d3                	mov    %edx,%ebx
  801d73:	c1 e3 08             	shl    $0x8,%ebx
  801d76:	89 d6                	mov    %edx,%esi
  801d78:	c1 e6 18             	shl    $0x18,%esi
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	c1 e0 10             	shl    $0x10,%eax
  801d80:	09 f0                	or     %esi,%eax
  801d82:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d84:	89 d8                	mov    %ebx,%eax
  801d86:	09 d0                	or     %edx,%eax
  801d88:	c1 e9 02             	shr    $0x2,%ecx
  801d8b:	fc                   	cld    
  801d8c:	f3 ab                	rep stos %eax,%es:(%edi)
  801d8e:	eb 06                	jmp    801d96 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d93:	fc                   	cld    
  801d94:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d96:	89 f8                	mov    %edi,%eax
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	57                   	push   %edi
  801da1:	56                   	push   %esi
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801da8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dab:	39 c6                	cmp    %eax,%esi
  801dad:	73 35                	jae    801de4 <memmove+0x47>
  801daf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801db2:	39 d0                	cmp    %edx,%eax
  801db4:	73 2e                	jae    801de4 <memmove+0x47>
		s += n;
		d += n;
  801db6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db9:	89 d6                	mov    %edx,%esi
  801dbb:	09 fe                	or     %edi,%esi
  801dbd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dc3:	75 13                	jne    801dd8 <memmove+0x3b>
  801dc5:	f6 c1 03             	test   $0x3,%cl
  801dc8:	75 0e                	jne    801dd8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801dca:	83 ef 04             	sub    $0x4,%edi
  801dcd:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dd0:	c1 e9 02             	shr    $0x2,%ecx
  801dd3:	fd                   	std    
  801dd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dd6:	eb 09                	jmp    801de1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dd8:	83 ef 01             	sub    $0x1,%edi
  801ddb:	8d 72 ff             	lea    -0x1(%edx),%esi
  801dde:	fd                   	std    
  801ddf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801de1:	fc                   	cld    
  801de2:	eb 1d                	jmp    801e01 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	f6 c2 03             	test   $0x3,%dl
  801deb:	75 0f                	jne    801dfc <memmove+0x5f>
  801ded:	f6 c1 03             	test   $0x3,%cl
  801df0:	75 0a                	jne    801dfc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801df2:	c1 e9 02             	shr    $0x2,%ecx
  801df5:	89 c7                	mov    %eax,%edi
  801df7:	fc                   	cld    
  801df8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dfa:	eb 05                	jmp    801e01 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dfc:	89 c7                	mov    %eax,%edi
  801dfe:	fc                   	cld    
  801dff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e01:	5e                   	pop    %esi
  801e02:	5f                   	pop    %edi
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    

00801e05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e08:	ff 75 10             	pushl  0x10(%ebp)
  801e0b:	ff 75 0c             	pushl  0xc(%ebp)
  801e0e:	ff 75 08             	pushl  0x8(%ebp)
  801e11:	e8 87 ff ff ff       	call   801d9d <memmove>
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e23:	89 c6                	mov    %eax,%esi
  801e25:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e28:	eb 1a                	jmp    801e44 <memcmp+0x2c>
		if (*s1 != *s2)
  801e2a:	0f b6 08             	movzbl (%eax),%ecx
  801e2d:	0f b6 1a             	movzbl (%edx),%ebx
  801e30:	38 d9                	cmp    %bl,%cl
  801e32:	74 0a                	je     801e3e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e34:	0f b6 c1             	movzbl %cl,%eax
  801e37:	0f b6 db             	movzbl %bl,%ebx
  801e3a:	29 d8                	sub    %ebx,%eax
  801e3c:	eb 0f                	jmp    801e4d <memcmp+0x35>
		s1++, s2++;
  801e3e:	83 c0 01             	add    $0x1,%eax
  801e41:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e44:	39 f0                	cmp    %esi,%eax
  801e46:	75 e2                	jne    801e2a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e58:	89 c1                	mov    %eax,%ecx
  801e5a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e5d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e61:	eb 0a                	jmp    801e6d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e63:	0f b6 10             	movzbl (%eax),%edx
  801e66:	39 da                	cmp    %ebx,%edx
  801e68:	74 07                	je     801e71 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e6a:	83 c0 01             	add    $0x1,%eax
  801e6d:	39 c8                	cmp    %ecx,%eax
  801e6f:	72 f2                	jb     801e63 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e71:	5b                   	pop    %ebx
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	57                   	push   %edi
  801e78:	56                   	push   %esi
  801e79:	53                   	push   %ebx
  801e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e80:	eb 03                	jmp    801e85 <strtol+0x11>
		s++;
  801e82:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e85:	0f b6 01             	movzbl (%ecx),%eax
  801e88:	3c 20                	cmp    $0x20,%al
  801e8a:	74 f6                	je     801e82 <strtol+0xe>
  801e8c:	3c 09                	cmp    $0x9,%al
  801e8e:	74 f2                	je     801e82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e90:	3c 2b                	cmp    $0x2b,%al
  801e92:	75 0a                	jne    801e9e <strtol+0x2a>
		s++;
  801e94:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e97:	bf 00 00 00 00       	mov    $0x0,%edi
  801e9c:	eb 11                	jmp    801eaf <strtol+0x3b>
  801e9e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ea3:	3c 2d                	cmp    $0x2d,%al
  801ea5:	75 08                	jne    801eaf <strtol+0x3b>
		s++, neg = 1;
  801ea7:	83 c1 01             	add    $0x1,%ecx
  801eaa:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eaf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801eb5:	75 15                	jne    801ecc <strtol+0x58>
  801eb7:	80 39 30             	cmpb   $0x30,(%ecx)
  801eba:	75 10                	jne    801ecc <strtol+0x58>
  801ebc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ec0:	75 7c                	jne    801f3e <strtol+0xca>
		s += 2, base = 16;
  801ec2:	83 c1 02             	add    $0x2,%ecx
  801ec5:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eca:	eb 16                	jmp    801ee2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	75 12                	jne    801ee2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ed0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ed5:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed8:	75 08                	jne    801ee2 <strtol+0x6e>
		s++, base = 8;
  801eda:	83 c1 01             	add    $0x1,%ecx
  801edd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eea:	0f b6 11             	movzbl (%ecx),%edx
  801eed:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ef0:	89 f3                	mov    %esi,%ebx
  801ef2:	80 fb 09             	cmp    $0x9,%bl
  801ef5:	77 08                	ja     801eff <strtol+0x8b>
			dig = *s - '0';
  801ef7:	0f be d2             	movsbl %dl,%edx
  801efa:	83 ea 30             	sub    $0x30,%edx
  801efd:	eb 22                	jmp    801f21 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eff:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f02:	89 f3                	mov    %esi,%ebx
  801f04:	80 fb 19             	cmp    $0x19,%bl
  801f07:	77 08                	ja     801f11 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f09:	0f be d2             	movsbl %dl,%edx
  801f0c:	83 ea 57             	sub    $0x57,%edx
  801f0f:	eb 10                	jmp    801f21 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f11:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f14:	89 f3                	mov    %esi,%ebx
  801f16:	80 fb 19             	cmp    $0x19,%bl
  801f19:	77 16                	ja     801f31 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f1b:	0f be d2             	movsbl %dl,%edx
  801f1e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f21:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f24:	7d 0b                	jge    801f31 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f26:	83 c1 01             	add    $0x1,%ecx
  801f29:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f2d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f2f:	eb b9                	jmp    801eea <strtol+0x76>

	if (endptr)
  801f31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f35:	74 0d                	je     801f44 <strtol+0xd0>
		*endptr = (char *) s;
  801f37:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f3a:	89 0e                	mov    %ecx,(%esi)
  801f3c:	eb 06                	jmp    801f44 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f3e:	85 db                	test   %ebx,%ebx
  801f40:	74 98                	je     801eda <strtol+0x66>
  801f42:	eb 9e                	jmp    801ee2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	f7 da                	neg    %edx
  801f48:	85 ff                	test   %edi,%edi
  801f4a:	0f 45 c2             	cmovne %edx,%eax
}
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	56                   	push   %esi
  801f56:	53                   	push   %ebx
  801f57:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f60:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f62:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f67:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f6a:	83 ec 0c             	sub    $0xc,%esp
  801f6d:	50                   	push   %eax
  801f6e:	e8 9b e3 ff ff       	call   80030e <sys_ipc_recv>

	if (r < 0) {
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	79 16                	jns    801f90 <ipc_recv+0x3e>
		if (from_env_store)
  801f7a:	85 f6                	test   %esi,%esi
  801f7c:	74 06                	je     801f84 <ipc_recv+0x32>
			*from_env_store = 0;
  801f7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f84:	85 db                	test   %ebx,%ebx
  801f86:	74 2c                	je     801fb4 <ipc_recv+0x62>
			*perm_store = 0;
  801f88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f8e:	eb 24                	jmp    801fb4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f90:	85 f6                	test   %esi,%esi
  801f92:	74 0a                	je     801f9e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f94:	a1 08 40 80 00       	mov    0x804008,%eax
  801f99:	8b 40 74             	mov    0x74(%eax),%eax
  801f9c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f9e:	85 db                	test   %ebx,%ebx
  801fa0:	74 0a                	je     801fac <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801fa2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa7:	8b 40 78             	mov    0x78(%eax),%eax
  801faa:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fac:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	57                   	push   %edi
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 0c             	sub    $0xc,%esp
  801fc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fcd:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801fcf:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fd4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801fd7:	ff 75 14             	pushl  0x14(%ebp)
  801fda:	53                   	push   %ebx
  801fdb:	56                   	push   %esi
  801fdc:	57                   	push   %edi
  801fdd:	e8 09 e3 ff ff       	call   8002eb <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe8:	75 07                	jne    801ff1 <ipc_send+0x36>
			sys_yield();
  801fea:	e8 50 e1 ff ff       	call   80013f <sys_yield>
  801fef:	eb e6                	jmp    801fd7 <ipc_send+0x1c>
		} else if (r < 0) {
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	79 12                	jns    802007 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ff5:	50                   	push   %eax
  801ff6:	68 c0 27 80 00       	push   $0x8027c0
  801ffb:	6a 51                	push   $0x51
  801ffd:	68 cd 27 80 00       	push   $0x8027cd
  802002:	e8 a6 f5 ff ff       	call   8015ad <_panic>
		}
	}
}
  802007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80201a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80201d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802023:	8b 52 50             	mov    0x50(%edx),%edx
  802026:	39 ca                	cmp    %ecx,%edx
  802028:	75 0d                	jne    802037 <ipc_find_env+0x28>
			return envs[i].env_id;
  80202a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80202d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802032:	8b 40 48             	mov    0x48(%eax),%eax
  802035:	eb 0f                	jmp    802046 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802037:	83 c0 01             	add    $0x1,%eax
  80203a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203f:	75 d9                	jne    80201a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204e:	89 d0                	mov    %edx,%eax
  802050:	c1 e8 16             	shr    $0x16,%eax
  802053:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205f:	f6 c1 01             	test   $0x1,%cl
  802062:	74 1d                	je     802081 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802064:	c1 ea 0c             	shr    $0xc,%edx
  802067:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206e:	f6 c2 01             	test   $0x1,%dl
  802071:	74 0e                	je     802081 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802073:	c1 ea 0c             	shr    $0xc,%edx
  802076:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80207d:	ef 
  80207e:	0f b7 c0             	movzwl %ax,%eax
}
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    
  802083:	66 90                	xchg   %ax,%ax
  802085:	66 90                	xchg   %ax,%ax
  802087:	66 90                	xchg   %ax,%ax
  802089:	66 90                	xchg   %ax,%ax
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
