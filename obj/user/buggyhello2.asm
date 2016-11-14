
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 b8 0f 80 00       	push   $0x800fb8
  800110:	6a 23                	push   $0x23
  800112:	68 d5 0f 80 00       	push   $0x800fd5
  800117:	e8 f5 01 00 00       	call   800311 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
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
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 b8 0f 80 00       	push   $0x800fb8
  800191:	6a 23                	push   $0x23
  800193:	68 d5 0f 80 00       	push   $0x800fd5
  800198:	e8 74 01 00 00       	call   800311 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 b8 0f 80 00       	push   $0x800fb8
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 d5 0f 80 00       	push   $0x800fd5
  8001da:	e8 32 01 00 00       	call   800311 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 b8 0f 80 00       	push   $0x800fb8
  800215:	6a 23                	push   $0x23
  800217:	68 d5 0f 80 00       	push   $0x800fd5
  80021c:	e8 f0 00 00 00       	call   800311 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 b8 0f 80 00       	push   $0x800fb8
  800257:	6a 23                	push   $0x23
  800259:	68 d5 0f 80 00       	push   $0x800fd5
  80025e:	e8 ae 00 00 00       	call   800311 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 b8 0f 80 00       	push   $0x800fb8
  800299:	6a 23                	push   $0x23
  80029b:	68 d5 0f 80 00       	push   $0x800fd5
  8002a0:	e8 6c 00 00 00       	call   800311 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 b8 0f 80 00       	push   $0x800fb8
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 d5 0f 80 00       	push   $0x800fd5
  800304:	e8 08 00 00 00       	call   800311 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 e4 0f 80 00       	push   $0x800fe4
  800334:	e8 b1 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 54 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  80034c:	e8 99 00 00 00       	call   8003ea <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	75 1a                	jne    800390 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	68 ff 00 00 00       	push   $0xff
  80037e:	8d 43 08             	lea    0x8(%ebx),%eax
  800381:	50                   	push   %eax
  800382:	e8 1f fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800390:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 57 03 80 00       	push   $0x800357
  8003c8:	e8 54 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800417:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800422:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800425:	39 d3                	cmp    %edx,%ebx
  800427:	72 05                	jb     80042e <printnum+0x30>
  800429:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042c:	77 45                	ja     800473 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff 75 18             	pushl  0x18(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043a:	53                   	push   %ebx
  80043b:	ff 75 10             	pushl  0x10(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 ae 08 00 00       	call   800d00 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 18                	jmp    80047d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 03                	jmp    800476 <printnum+0x78>
  800473:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f e8                	jg     800465 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	e8 9b 09 00 00       	call   800e30 <__umoddi3>
  800495:	83 c4 14             	add    $0x14,%esp
  800498:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff d7                	call   *%edi
}
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a8:	5b                   	pop    %ebx
  8004a9:	5e                   	pop    %esi
  8004aa:	5f                   	pop    %edi
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b0:	83 fa 01             	cmp    $0x1,%edx
  8004b3:	7e 0e                	jle    8004c3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	8b 52 04             	mov    0x4(%edx),%edx
  8004c1:	eb 22                	jmp    8004e5 <getuint+0x38>
	else if (lflag)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 10                	je     8004d7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d5:	eb 0e                	jmp    8004e5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dc:	89 08                	mov    %ecx,(%eax)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f6:	73 0a                	jae    800502 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fb:	89 08                	mov    %ecx,(%eax)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	88 02                	mov    %al,(%edx)
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
}
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 75 08             	mov    0x8(%ebp),%esi
  80052d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800530:	8b 7d 10             	mov    0x10(%ebp),%edi
  800533:	eb 1d                	jmp    800552 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800535:	85 c0                	test   %eax,%eax
  800537:	75 0f                	jne    800548 <vprintfmt+0x27>
				csa = 0x0700;
  800539:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  800540:	07 00 00 
				return;
  800543:	e9 c4 03 00 00       	jmp    80090c <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	50                   	push   %eax
  80054d:	ff d6                	call   *%esi
  80054f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	83 f8 25             	cmp    $0x25,%eax
  80055c:	75 d7                	jne    800535 <vprintfmt+0x14>
  80055e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800562:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800569:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800570:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800577:	ba 00 00 00 00       	mov    $0x0,%edx
  80057c:	eb 07                	jmp    800585 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800581:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8d 47 01             	lea    0x1(%edi),%eax
  800588:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058b:	0f b6 07             	movzbl (%edi),%eax
  80058e:	0f b6 c8             	movzbl %al,%ecx
  800591:	83 e8 23             	sub    $0x23,%eax
  800594:	3c 55                	cmp    $0x55,%al
  800596:	0f 87 55 03 00 00    	ja     8008f1 <vprintfmt+0x3d0>
  80059c:	0f b6 c0             	movzbl %al,%eax
  80059f:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ad:	eb d6                	jmp    800585 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c7:	83 fa 09             	cmp    $0x9,%edx
  8005ca:	77 39                	ja     800605 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cf:	eb e9                	jmp    8005ba <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e2:	eb 27                	jmp    80060b <vprintfmt+0xea>
  8005e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ee:	0f 49 c8             	cmovns %eax,%ecx
  8005f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f7:	eb 8c                	jmp    800585 <vprintfmt+0x64>
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800603:	eb 80                	jmp    800585 <vprintfmt+0x64>
  800605:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80060b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060f:	0f 89 70 ff ff ff    	jns    800585 <vprintfmt+0x64>
				width = precision, precision = -1;
  800615:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800618:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800622:	e9 5e ff ff ff       	jmp    800585 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800627:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062d:	e9 53 ff ff ff       	jmp    800585 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	ff 30                	pushl  (%eax)
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800649:	e9 04 ff ff ff       	jmp    800552 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	99                   	cltd   
  80065a:	31 d0                	xor    %edx,%eax
  80065c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065e:	83 f8 08             	cmp    $0x8,%eax
  800661:	7f 0b                	jg     80066e <vprintfmt+0x14d>
  800663:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80066a:	85 d2                	test   %edx,%edx
  80066c:	75 18                	jne    800686 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80066e:	50                   	push   %eax
  80066f:	68 20 10 80 00       	push   $0x801020
  800674:	53                   	push   %ebx
  800675:	56                   	push   %esi
  800676:	e8 89 fe ff ff       	call   800504 <printfmt>
  80067b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800681:	e9 cc fe ff ff       	jmp    800552 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800686:	52                   	push   %edx
  800687:	68 29 10 80 00       	push   $0x801029
  80068c:	53                   	push   %ebx
  80068d:	56                   	push   %esi
  80068e:	e8 71 fe ff ff       	call   800504 <printfmt>
  800693:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800699:	e9 b4 fe ff ff       	jmp    800552 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a9:	85 ff                	test   %edi,%edi
  8006ab:	b8 19 10 80 00       	mov    $0x801019,%eax
  8006b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b7:	0f 8e 94 00 00 00    	jle    800751 <vprintfmt+0x230>
  8006bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c1:	0f 84 98 00 00 00    	je     80075f <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8006cd:	57                   	push   %edi
  8006ce:	e8 c1 02 00 00       	call   800994 <strnlen>
  8006d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d6:	29 c1                	sub    %eax,%ecx
  8006d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006db:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006de:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ea:	eb 0f                	jmp    8006fb <vprintfmt+0x1da>
					putch(padc, putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	85 ff                	test   %edi,%edi
  8006fd:	7f ed                	jg     8006ec <vprintfmt+0x1cb>
  8006ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800702:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800705:	85 c9                	test   %ecx,%ecx
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	0f 49 c1             	cmovns %ecx,%eax
  80070f:	29 c1                	sub    %eax,%ecx
  800711:	89 75 08             	mov    %esi,0x8(%ebp)
  800714:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800717:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071a:	89 cb                	mov    %ecx,%ebx
  80071c:	eb 4d                	jmp    80076b <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800722:	74 1b                	je     80073f <vprintfmt+0x21e>
  800724:	0f be c0             	movsbl %al,%eax
  800727:	83 e8 20             	sub    $0x20,%eax
  80072a:	83 f8 5e             	cmp    $0x5e,%eax
  80072d:	76 10                	jbe    80073f <vprintfmt+0x21e>
					putch('?', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	6a 3f                	push   $0x3f
  800737:	ff 55 08             	call   *0x8(%ebp)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 0d                	jmp    80074c <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	52                   	push   %edx
  800746:	ff 55 08             	call   *0x8(%ebp)
  800749:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074c:	83 eb 01             	sub    $0x1,%ebx
  80074f:	eb 1a                	jmp    80076b <vprintfmt+0x24a>
  800751:	89 75 08             	mov    %esi,0x8(%ebp)
  800754:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800757:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075d:	eb 0c                	jmp    80076b <vprintfmt+0x24a>
  80075f:	89 75 08             	mov    %esi,0x8(%ebp)
  800762:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800765:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800768:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076b:	83 c7 01             	add    $0x1,%edi
  80076e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800772:	0f be d0             	movsbl %al,%edx
  800775:	85 d2                	test   %edx,%edx
  800777:	74 23                	je     80079c <vprintfmt+0x27b>
  800779:	85 f6                	test   %esi,%esi
  80077b:	78 a1                	js     80071e <vprintfmt+0x1fd>
  80077d:	83 ee 01             	sub    $0x1,%esi
  800780:	79 9c                	jns    80071e <vprintfmt+0x1fd>
  800782:	89 df                	mov    %ebx,%edi
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078a:	eb 18                	jmp    8007a4 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 20                	push   $0x20
  800792:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800794:	83 ef 01             	sub    $0x1,%edi
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 08                	jmp    8007a4 <vprintfmt+0x283>
  80079c:	89 df                	mov    %ebx,%edi
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a4:	85 ff                	test   %edi,%edi
  8007a6:	7f e4                	jg     80078c <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ab:	e9 a2 fd ff ff       	jmp    800552 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b0:	83 fa 01             	cmp    $0x1,%edx
  8007b3:	7e 16                	jle    8007cb <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 08             	lea    0x8(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007be:	8b 50 04             	mov    0x4(%eax),%edx
  8007c1:	8b 00                	mov    (%eax),%eax
  8007c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c9:	eb 32                	jmp    8007fd <vprintfmt+0x2dc>
	else if (lflag)
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 18                	je     8007e7 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dd:	89 c1                	mov    %eax,%ecx
  8007df:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e5:	eb 16                	jmp    8007fd <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 50 04             	lea    0x4(%eax),%edx
  8007ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 c1                	mov    %eax,%ecx
  8007f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800800:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800803:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800808:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080c:	79 74                	jns    800882 <vprintfmt+0x361>
				putch('-', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 2d                	push   $0x2d
  800814:	ff d6                	call   *%esi
				num = -(long long) num;
  800816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800819:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80081c:	f7 d8                	neg    %eax
  80081e:	83 d2 00             	adc    $0x0,%edx
  800821:	f7 da                	neg    %edx
  800823:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800826:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082b:	eb 55                	jmp    800882 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
  800830:	e8 78 fc ff ff       	call   8004ad <getuint>
			base = 10;
  800835:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80083a:	eb 46                	jmp    800882 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80083c:	8d 45 14             	lea    0x14(%ebp),%eax
  80083f:	e8 69 fc ff ff       	call   8004ad <getuint>
      base = 8;
  800844:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800849:	eb 37                	jmp    800882 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 30                	push   $0x30
  800851:	ff d6                	call   *%esi
			putch('x', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 78                	push   $0x78
  800859:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800864:	8b 00                	mov    (%eax),%eax
  800866:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800873:	eb 0d                	jmp    800882 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	e8 30 fc ff ff       	call   8004ad <getuint>
			base = 16;
  80087d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800889:	57                   	push   %edi
  80088a:	ff 75 e0             	pushl  -0x20(%ebp)
  80088d:	51                   	push   %ecx
  80088e:	52                   	push   %edx
  80088f:	50                   	push   %eax
  800890:	89 da                	mov    %ebx,%edx
  800892:	89 f0                	mov    %esi,%eax
  800894:	e8 65 fb ff ff       	call   8003fe <printnum>
			break;
  800899:	83 c4 20             	add    $0x20,%esp
  80089c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089f:	e9 ae fc ff ff       	jmp    800552 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	51                   	push   %ecx
  8008a9:	ff d6                	call   *%esi
			break;
  8008ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b1:	e9 9c fc ff ff       	jmp    800552 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b6:	83 fa 01             	cmp    $0x1,%edx
  8008b9:	7e 0d                	jle    8008c8 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 50 08             	lea    0x8(%eax),%edx
  8008c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c4:	8b 00                	mov    (%eax),%eax
  8008c6:	eb 1c                	jmp    8008e4 <vprintfmt+0x3c3>
	else if (lflag)
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	74 0d                	je     8008d9 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8d 50 04             	lea    0x4(%eax),%edx
  8008d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d5:	8b 00                	mov    (%eax),%eax
  8008d7:	eb 0b                	jmp    8008e4 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 50 04             	lea    0x4(%eax),%edx
  8008df:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e2:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008e4:	a3 0c 20 80 00       	mov    %eax,0x80200c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008ec:	e9 61 fc ff ff       	jmp    800552 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 25                	push   $0x25
  8008f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	eb 03                	jmp    800901 <vprintfmt+0x3e0>
  8008fe:	83 ef 01             	sub    $0x1,%edi
  800901:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800905:	75 f7                	jne    8008fe <vprintfmt+0x3dd>
  800907:	e9 46 fc ff ff       	jmp    800552 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80090c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	83 ec 18             	sub    $0x18,%esp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800920:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800923:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800927:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800931:	85 c0                	test   %eax,%eax
  800933:	74 26                	je     80095b <vsnprintf+0x47>
  800935:	85 d2                	test   %edx,%edx
  800937:	7e 22                	jle    80095b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800939:	ff 75 14             	pushl  0x14(%ebp)
  80093c:	ff 75 10             	pushl  0x10(%ebp)
  80093f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800942:	50                   	push   %eax
  800943:	68 e7 04 80 00       	push   $0x8004e7
  800948:	e8 d4 fb ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800950:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	eb 05                	jmp    800960 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800968:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096b:	50                   	push   %eax
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 9a ff ff ff       	call   800914 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
  800987:	eb 03                	jmp    80098c <strlen+0x10>
		n++;
  800989:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800990:	75 f7                	jne    800989 <strlen+0xd>
		n++;
	return n;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099d:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a2:	eb 03                	jmp    8009a7 <strnlen+0x13>
		n++;
  8009a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	74 08                	je     8009b3 <strnlen+0x1f>
  8009ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009af:	75 f3                	jne    8009a4 <strnlen+0x10>
  8009b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	83 c1 01             	add    $0x1,%ecx
  8009c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ce:	84 db                	test   %bl,%bl
  8009d0:	75 ef                	jne    8009c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009dc:	53                   	push   %ebx
  8009dd:	e8 9a ff ff ff       	call   80097c <strlen>
  8009e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	01 d8                	add    %ebx,%eax
  8009ea:	50                   	push   %eax
  8009eb:	e8 c5 ff ff ff       	call   8009b5 <strcpy>
	return dst;
}
  8009f0:	89 d8                	mov    %ebx,%eax
  8009f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a07:	89 f2                	mov    %esi,%edx
  800a09:	eb 0f                	jmp    800a1a <strncpy+0x23>
		*dst++ = *src;
  800a0b:	83 c2 01             	add    $0x1,%edx
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a14:	80 39 01             	cmpb   $0x1,(%ecx)
  800a17:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1a:	39 da                	cmp    %ebx,%edx
  800a1c:	75 ed                	jne    800a0b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1e:	89 f0                	mov    %esi,%eax
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a32:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a34:	85 d2                	test   %edx,%edx
  800a36:	74 21                	je     800a59 <strlcpy+0x35>
  800a38:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3c:	89 f2                	mov    %esi,%edx
  800a3e:	eb 09                	jmp    800a49 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a40:	83 c2 01             	add    $0x1,%edx
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a49:	39 c2                	cmp    %eax,%edx
  800a4b:	74 09                	je     800a56 <strlcpy+0x32>
  800a4d:	0f b6 19             	movzbl (%ecx),%ebx
  800a50:	84 db                	test   %bl,%bl
  800a52:	75 ec                	jne    800a40 <strlcpy+0x1c>
  800a54:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a56:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a59:	29 f0                	sub    %esi,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a68:	eb 06                	jmp    800a70 <strcmp+0x11>
		p++, q++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a70:	0f b6 01             	movzbl (%ecx),%eax
  800a73:	84 c0                	test   %al,%al
  800a75:	74 04                	je     800a7b <strcmp+0x1c>
  800a77:	3a 02                	cmp    (%edx),%al
  800a79:	74 ef                	je     800a6a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7b:	0f b6 c0             	movzbl %al,%eax
  800a7e:	0f b6 12             	movzbl (%edx),%edx
  800a81:	29 d0                	sub    %edx,%eax
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a94:	eb 06                	jmp    800a9c <strncmp+0x17>
		n--, p++, q++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9c:	39 d8                	cmp    %ebx,%eax
  800a9e:	74 15                	je     800ab5 <strncmp+0x30>
  800aa0:	0f b6 08             	movzbl (%eax),%ecx
  800aa3:	84 c9                	test   %cl,%cl
  800aa5:	74 04                	je     800aab <strncmp+0x26>
  800aa7:	3a 0a                	cmp    (%edx),%cl
  800aa9:	74 eb                	je     800a96 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aab:	0f b6 00             	movzbl (%eax),%eax
  800aae:	0f b6 12             	movzbl (%edx),%edx
  800ab1:	29 d0                	sub    %edx,%eax
  800ab3:	eb 05                	jmp    800aba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac7:	eb 07                	jmp    800ad0 <strchr+0x13>
		if (*s == c)
  800ac9:	38 ca                	cmp    %cl,%dl
  800acb:	74 0f                	je     800adc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	0f b6 10             	movzbl (%eax),%edx
  800ad3:	84 d2                	test   %dl,%dl
  800ad5:	75 f2                	jne    800ac9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae8:	eb 03                	jmp    800aed <strfind+0xf>
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 04                	je     800af8 <strfind+0x1a>
  800af4:	84 d2                	test   %dl,%dl
  800af6:	75 f2                	jne    800aea <strfind+0xc>
			break;
	return (char *) s;
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b06:	85 c9                	test   %ecx,%ecx
  800b08:	74 36                	je     800b40 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b10:	75 28                	jne    800b3a <memset+0x40>
  800b12:	f6 c1 03             	test   $0x3,%cl
  800b15:	75 23                	jne    800b3a <memset+0x40>
		c &= 0xFF;
  800b17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	c1 e3 08             	shl    $0x8,%ebx
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	c1 e6 18             	shl    $0x18,%esi
  800b25:	89 d0                	mov    %edx,%eax
  800b27:	c1 e0 10             	shl    $0x10,%eax
  800b2a:	09 f0                	or     %esi,%eax
  800b2c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b2e:	89 d8                	mov    %ebx,%eax
  800b30:	09 d0                	or     %edx,%eax
  800b32:	c1 e9 02             	shr    $0x2,%ecx
  800b35:	fc                   	cld    
  800b36:	f3 ab                	rep stos %eax,%es:(%edi)
  800b38:	eb 06                	jmp    800b40 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	fc                   	cld    
  800b3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b40:	89 f8                	mov    %edi,%eax
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b55:	39 c6                	cmp    %eax,%esi
  800b57:	73 35                	jae    800b8e <memmove+0x47>
  800b59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5c:	39 d0                	cmp    %edx,%eax
  800b5e:	73 2e                	jae    800b8e <memmove+0x47>
		s += n;
		d += n;
  800b60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	09 fe                	or     %edi,%esi
  800b67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6d:	75 13                	jne    800b82 <memmove+0x3b>
  800b6f:	f6 c1 03             	test   $0x3,%cl
  800b72:	75 0e                	jne    800b82 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b74:	83 ef 04             	sub    $0x4,%edi
  800b77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7a:	c1 e9 02             	shr    $0x2,%ecx
  800b7d:	fd                   	std    
  800b7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b80:	eb 09                	jmp    800b8b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b82:	83 ef 01             	sub    $0x1,%edi
  800b85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b88:	fd                   	std    
  800b89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8b:	fc                   	cld    
  800b8c:	eb 1d                	jmp    800bab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8e:	89 f2                	mov    %esi,%edx
  800b90:	09 c2                	or     %eax,%edx
  800b92:	f6 c2 03             	test   $0x3,%dl
  800b95:	75 0f                	jne    800ba6 <memmove+0x5f>
  800b97:	f6 c1 03             	test   $0x3,%cl
  800b9a:	75 0a                	jne    800ba6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba4:	eb 05                	jmp    800bab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb2:	ff 75 10             	pushl  0x10(%ebp)
  800bb5:	ff 75 0c             	pushl  0xc(%ebp)
  800bb8:	ff 75 08             	pushl  0x8(%ebp)
  800bbb:	e8 87 ff ff ff       	call   800b47 <memmove>
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd2:	eb 1a                	jmp    800bee <memcmp+0x2c>
		if (*s1 != *s2)
  800bd4:	0f b6 08             	movzbl (%eax),%ecx
  800bd7:	0f b6 1a             	movzbl (%edx),%ebx
  800bda:	38 d9                	cmp    %bl,%cl
  800bdc:	74 0a                	je     800be8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bde:	0f b6 c1             	movzbl %cl,%eax
  800be1:	0f b6 db             	movzbl %bl,%ebx
  800be4:	29 d8                	sub    %ebx,%eax
  800be6:	eb 0f                	jmp    800bf7 <memcmp+0x35>
		s1++, s2++;
  800be8:	83 c0 01             	add    $0x1,%eax
  800beb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	39 f0                	cmp    %esi,%eax
  800bf0:	75 e2                	jne    800bd4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c02:	89 c1                	mov    %eax,%ecx
  800c04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0b:	eb 0a                	jmp    800c17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	39 da                	cmp    %ebx,%edx
  800c12:	74 07                	je     800c1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c14:	83 c0 01             	add    $0x1,%eax
  800c17:	39 c8                	cmp    %ecx,%eax
  800c19:	72 f2                	jb     800c0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2a:	eb 03                	jmp    800c2f <strtol+0x11>
		s++;
  800c2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	0f b6 01             	movzbl (%ecx),%eax
  800c32:	3c 20                	cmp    $0x20,%al
  800c34:	74 f6                	je     800c2c <strtol+0xe>
  800c36:	3c 09                	cmp    $0x9,%al
  800c38:	74 f2                	je     800c2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3a:	3c 2b                	cmp    $0x2b,%al
  800c3c:	75 0a                	jne    800c48 <strtol+0x2a>
		s++;
  800c3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c41:	bf 00 00 00 00       	mov    $0x0,%edi
  800c46:	eb 11                	jmp    800c59 <strtol+0x3b>
  800c48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c4d:	3c 2d                	cmp    $0x2d,%al
  800c4f:	75 08                	jne    800c59 <strtol+0x3b>
		s++, neg = 1;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5f:	75 15                	jne    800c76 <strtol+0x58>
  800c61:	80 39 30             	cmpb   $0x30,(%ecx)
  800c64:	75 10                	jne    800c76 <strtol+0x58>
  800c66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6a:	75 7c                	jne    800ce8 <strtol+0xca>
		s += 2, base = 16;
  800c6c:	83 c1 02             	add    $0x2,%ecx
  800c6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c74:	eb 16                	jmp    800c8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c76:	85 db                	test   %ebx,%ebx
  800c78:	75 12                	jne    800c8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c82:	75 08                	jne    800c8c <strtol+0x6e>
		s++, base = 8;
  800c84:	83 c1 01             	add    $0x1,%ecx
  800c87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c94:	0f b6 11             	movzbl (%ecx),%edx
  800c97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9a:	89 f3                	mov    %esi,%ebx
  800c9c:	80 fb 09             	cmp    $0x9,%bl
  800c9f:	77 08                	ja     800ca9 <strtol+0x8b>
			dig = *s - '0';
  800ca1:	0f be d2             	movsbl %dl,%edx
  800ca4:	83 ea 30             	sub    $0x30,%edx
  800ca7:	eb 22                	jmp    800ccb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cac:	89 f3                	mov    %esi,%ebx
  800cae:	80 fb 19             	cmp    $0x19,%bl
  800cb1:	77 08                	ja     800cbb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb3:	0f be d2             	movsbl %dl,%edx
  800cb6:	83 ea 57             	sub    $0x57,%edx
  800cb9:	eb 10                	jmp    800ccb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cbe:	89 f3                	mov    %esi,%ebx
  800cc0:	80 fb 19             	cmp    $0x19,%bl
  800cc3:	77 16                	ja     800cdb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc5:	0f be d2             	movsbl %dl,%edx
  800cc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ccb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cce:	7d 0b                	jge    800cdb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd0:	83 c1 01             	add    $0x1,%ecx
  800cd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd9:	eb b9                	jmp    800c94 <strtol+0x76>

	if (endptr)
  800cdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdf:	74 0d                	je     800cee <strtol+0xd0>
		*endptr = (char *) s;
  800ce1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce4:	89 0e                	mov    %ecx,(%esi)
  800ce6:	eb 06                	jmp    800cee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	74 98                	je     800c84 <strtol+0x66>
  800cec:	eb 9e                	jmp    800c8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cee:	89 c2                	mov    %eax,%edx
  800cf0:	f7 da                	neg    %edx
  800cf2:	85 ff                	test   %edi,%edi
  800cf4:	0f 45 c2             	cmovne %edx,%eax
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
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
