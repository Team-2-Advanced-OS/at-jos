
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
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
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

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
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 f8 1d 80 00       	push   $0x801df8
  800118:	6a 23                	push   $0x23
  80011a:	68 15 1e 80 00       	push   $0x801e15
  80011f:	e8 4a 0f 00 00       	call   80106e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 f8 1d 80 00       	push   $0x801df8
  800199:	6a 23                	push   $0x23
  80019b:	68 15 1e 80 00       	push   $0x801e15
  8001a0:	e8 c9 0e 00 00       	call   80106e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 f8 1d 80 00       	push   $0x801df8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 15 1e 80 00       	push   $0x801e15
  8001e2:	e8 87 0e 00 00       	call   80106e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 f8 1d 80 00       	push   $0x801df8
  80021d:	6a 23                	push   $0x23
  80021f:	68 15 1e 80 00       	push   $0x801e15
  800224:	e8 45 0e 00 00       	call   80106e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 f8 1d 80 00       	push   $0x801df8
  80025f:	6a 23                	push   $0x23
  800261:	68 15 1e 80 00       	push   $0x801e15
  800266:	e8 03 0e 00 00       	call   80106e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 f8 1d 80 00       	push   $0x801df8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 15 1e 80 00       	push   $0x801e15
  8002a8:	e8 c1 0d 00 00       	call   80106e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 f8 1d 80 00       	push   $0x801df8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 15 1e 80 00       	push   $0x801e15
  8002ea:	e8 7f 0d 00 00       	call   80106e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 f8 1d 80 00       	push   $0x801df8
  800347:	6a 23                	push   $0x23
  800349:	68 15 1e 80 00       	push   $0x801e15
  80034e:	e8 1b 0d 00 00       	call   80106e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 24 1e 80 00       	push   $0x801e24
  800462:	e8 e0 0c 00 00       	call   801147 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 65 1e 80 00       	push   $0x801e65
  80068c:	e8 b6 0a 00 00       	call   801147 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 81 1e 80 00       	push   $0x801e81
  800761:	e8 e1 09 00 00       	call   801147 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 44 1e 80 00       	push   $0x801e44
  800816:	e8 2c 09 00 00       	call   801147 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 0c 02 00 00       	call   800aeb <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 aa 11 00 00       	call   801ad0 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 3b 11 00 00       	call   801a7c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 c5 10 00 00       	call   801a13 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 f5 0c 00 00       	call   8016cc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0a:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a10:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a15:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a1a:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a1d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a23:	53                   	push   %ebx
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	68 08 50 80 00       	push   $0x805008
  800a2c:	e8 2d 0e 00 00       	call   80185e <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3b:	e8 ca fe ff ff       	call   80090a <fsipc>
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	85 c0                	test   %eax,%eax
  800a45:	78 1d                	js     800a64 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a47:	39 d8                	cmp    %ebx,%eax
  800a49:	76 19                	jbe    800a64 <devfile_write+0x6a>
  800a4b:	68 b0 1e 80 00       	push   $0x801eb0
  800a50:	68 bc 1e 80 00       	push   $0x801ebc
  800a55:	68 a5 00 00 00       	push   $0xa5
  800a5a:	68 d1 1e 80 00       	push   $0x801ed1
  800a5f:	e8 0a 06 00 00       	call   80106e <_panic>
	return r;
}
  800a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 40 0c             	mov    0xc(%eax),%eax
  800a77:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8c:	e8 79 fe ff ff       	call   80090a <fsipc>
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 4b                	js     800ae2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a97:	39 c6                	cmp    %eax,%esi
  800a99:	73 16                	jae    800ab1 <devfile_read+0x48>
  800a9b:	68 dc 1e 80 00       	push   $0x801edc
  800aa0:	68 bc 1e 80 00       	push   $0x801ebc
  800aa5:	6a 7c                	push   $0x7c
  800aa7:	68 d1 1e 80 00       	push   $0x801ed1
  800aac:	e8 bd 05 00 00       	call   80106e <_panic>
	assert(r <= PGSIZE);
  800ab1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab6:	7e 16                	jle    800ace <devfile_read+0x65>
  800ab8:	68 e3 1e 80 00       	push   $0x801ee3
  800abd:	68 bc 1e 80 00       	push   $0x801ebc
  800ac2:	6a 7d                	push   $0x7d
  800ac4:	68 d1 1e 80 00       	push   $0x801ed1
  800ac9:	e8 a0 05 00 00       	call   80106e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ace:	83 ec 04             	sub    $0x4,%esp
  800ad1:	50                   	push   %eax
  800ad2:	68 00 50 80 00       	push   $0x805000
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	e8 7f 0d 00 00       	call   80185e <memmove>
	return r;
  800adf:	83 c4 10             	add    $0x10,%esp
}
  800ae2:	89 d8                	mov    %ebx,%eax
  800ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	83 ec 20             	sub    $0x20,%esp
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af5:	53                   	push   %ebx
  800af6:	e8 98 0b 00 00       	call   801693 <strlen>
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b03:	7f 67                	jg     800b6c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0b:	50                   	push   %eax
  800b0c:	e8 71 f8 ff ff       	call   800382 <fd_alloc>
  800b11:	83 c4 10             	add    $0x10,%esp
		return r;
  800b14:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 57                	js     800b71 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	53                   	push   %ebx
  800b1e:	68 00 50 80 00       	push   $0x805000
  800b23:	e8 a4 0b 00 00       	call   8016cc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	e8 cd fd ff ff       	call   80090a <fsipc>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	79 14                	jns    800b5a <open+0x6f>
		fd_close(fd, 0);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	6a 00                	push   $0x0
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 27 f9 ff ff       	call   80047a <fd_close>
		return r;
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	89 da                	mov    %ebx,%edx
  800b58:	eb 17                	jmp    800b71 <open+0x86>
	}

	return fd2num(fd);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b60:	e8 f6 f7 ff ff       	call   80035b <fd2num>
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	eb 05                	jmp    800b71 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b71:	89 d0                	mov    %edx,%eax
  800b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 08 00 00 00       	mov    $0x8,%eax
  800b88:	e8 7d fd ff ff       	call   80090a <fsipc>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	ff 75 08             	pushl  0x8(%ebp)
  800b9d:	e8 c9 f7 ff ff       	call   80036b <fd2data>
  800ba2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba4:	83 c4 08             	add    $0x8,%esp
  800ba7:	68 ef 1e 80 00       	push   $0x801eef
  800bac:	53                   	push   %ebx
  800bad:	e8 1a 0b 00 00       	call   8016cc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb2:	8b 46 04             	mov    0x4(%esi),%eax
  800bb5:	2b 06                	sub    (%esi),%eax
  800bb7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc4:	00 00 00 
	stat->st_dev = &devpipe;
  800bc7:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bce:	30 80 00 
	return 0;
}
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be7:	53                   	push   %ebx
  800be8:	6a 00                	push   $0x0
  800bea:	e8 00 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bef:	89 1c 24             	mov    %ebx,(%esp)
  800bf2:	e8 74 f7 ff ff       	call   80036b <fd2data>
  800bf7:	83 c4 08             	add    $0x8,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 00                	push   $0x0
  800bfd:	e8 ed f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800c02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 1c             	sub    $0x1c,%esp
  800c10:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c13:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c15:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	ff 75 e0             	pushl  -0x20(%ebp)
  800c23:	e8 e1 0e 00 00       	call   801b09 <pageref>
  800c28:	89 c3                	mov    %eax,%ebx
  800c2a:	89 3c 24             	mov    %edi,(%esp)
  800c2d:	e8 d7 0e 00 00       	call   801b09 <pageref>
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	39 c3                	cmp    %eax,%ebx
  800c37:	0f 94 c1             	sete   %cl
  800c3a:	0f b6 c9             	movzbl %cl,%ecx
  800c3d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c40:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c46:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c49:	39 ce                	cmp    %ecx,%esi
  800c4b:	74 1b                	je     800c68 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c4d:	39 c3                	cmp    %eax,%ebx
  800c4f:	75 c4                	jne    800c15 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c51:	8b 42 58             	mov    0x58(%edx),%eax
  800c54:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c57:	50                   	push   %eax
  800c58:	56                   	push   %esi
  800c59:	68 f6 1e 80 00       	push   $0x801ef6
  800c5e:	e8 e4 04 00 00       	call   801147 <cprintf>
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	eb ad                	jmp    800c15 <_pipeisclosed+0xe>
	}
}
  800c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 28             	sub    $0x28,%esp
  800c7c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c7f:	56                   	push   %esi
  800c80:	e8 e6 f6 ff ff       	call   80036b <fd2data>
  800c85:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8f:	eb 4b                	jmp    800cdc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	e8 6d ff ff ff       	call   800c07 <_pipeisclosed>
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	75 48                	jne    800ce6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c9e:	e8 a8 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca6:	8b 0b                	mov    (%ebx),%ecx
  800ca8:	8d 51 20             	lea    0x20(%ecx),%edx
  800cab:	39 d0                	cmp    %edx,%eax
  800cad:	73 e2                	jae    800c91 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb9:	89 c2                	mov    %eax,%edx
  800cbb:	c1 fa 1f             	sar    $0x1f,%edx
  800cbe:	89 d1                	mov    %edx,%ecx
  800cc0:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc6:	83 e2 1f             	and    $0x1f,%edx
  800cc9:	29 ca                	sub    %ecx,%edx
  800ccb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ccf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd9:	83 c7 01             	add    $0x1,%edi
  800cdc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cdf:	75 c2                	jne    800ca3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce4:	eb 05                	jmp    800ceb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 18             	sub    $0x18,%esp
  800cfc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cff:	57                   	push   %edi
  800d00:	e8 66 f6 ff ff       	call   80036b <fd2data>
  800d05:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	eb 3d                	jmp    800d4e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d11:	85 db                	test   %ebx,%ebx
  800d13:	74 04                	je     800d19 <devpipe_read+0x26>
				return i;
  800d15:	89 d8                	mov    %ebx,%eax
  800d17:	eb 44                	jmp    800d5d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	e8 e5 fe ff ff       	call   800c07 <_pipeisclosed>
  800d22:	85 c0                	test   %eax,%eax
  800d24:	75 32                	jne    800d58 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d26:	e8 20 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d2b:	8b 06                	mov    (%esi),%eax
  800d2d:	3b 46 04             	cmp    0x4(%esi),%eax
  800d30:	74 df                	je     800d11 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d32:	99                   	cltd   
  800d33:	c1 ea 1b             	shr    $0x1b,%edx
  800d36:	01 d0                	add    %edx,%eax
  800d38:	83 e0 1f             	and    $0x1f,%eax
  800d3b:	29 d0                	sub    %edx,%eax
  800d3d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d48:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d4b:	83 c3 01             	add    $0x1,%ebx
  800d4e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d51:	75 d8                	jne    800d2b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d53:	8b 45 10             	mov    0x10(%ebp),%eax
  800d56:	eb 05                	jmp    800d5d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d70:	50                   	push   %eax
  800d71:	e8 0c f6 ff ff       	call   800382 <fd_alloc>
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	0f 88 2c 01 00 00    	js     800eaf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	68 07 04 00 00       	push   $0x407
  800d8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8e:	6a 00                	push   $0x0
  800d90:	e8 d5 f3 ff ff       	call   80016a <sys_page_alloc>
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 0d 01 00 00    	js     800eaf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da8:	50                   	push   %eax
  800da9:	e8 d4 f5 ff ff       	call   800382 <fd_alloc>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 e2 00 00 00    	js     800e9d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	68 07 04 00 00       	push   $0x407
  800dc3:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 9d f3 ff ff       	call   80016a <sys_page_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 c3 00 00 00    	js     800e9d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	ff 75 f4             	pushl  -0xc(%ebp)
  800de0:	e8 86 f5 ff ff       	call   80036b <fd2data>
  800de5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de7:	83 c4 0c             	add    $0xc,%esp
  800dea:	68 07 04 00 00       	push   $0x407
  800def:	50                   	push   %eax
  800df0:	6a 00                	push   $0x0
  800df2:	e8 73 f3 ff ff       	call   80016a <sys_page_alloc>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	0f 88 89 00 00 00    	js     800e8d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0a:	e8 5c f5 ff ff       	call   80036b <fd2data>
  800e0f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e16:	50                   	push   %eax
  800e17:	6a 00                	push   $0x0
  800e19:	56                   	push   %esi
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 8c f3 ff ff       	call   8001ad <sys_page_map>
  800e21:	89 c3                	mov    %eax,%ebx
  800e23:	83 c4 20             	add    $0x20,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	78 55                	js     800e7f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e33:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e38:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e3f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e48:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5a:	e8 fc f4 ff ff       	call   80035b <fd2num>
  800e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e62:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e64:	83 c4 04             	add    $0x4,%esp
  800e67:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6a:	e8 ec f4 ff ff       	call   80035b <fd2num>
  800e6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e72:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7d:	eb 30                	jmp    800eaf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	56                   	push   %esi
  800e83:	6a 00                	push   $0x0
  800e85:	e8 65 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e8a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	ff 75 f0             	pushl  -0x10(%ebp)
  800e93:	6a 00                	push   $0x0
  800e95:	e8 55 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e9a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 45 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec1:	50                   	push   %eax
  800ec2:	ff 75 08             	pushl  0x8(%ebp)
  800ec5:	e8 07 f5 ff ff       	call   8003d1 <fd_lookup>
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	78 18                	js     800ee9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed7:	e8 8f f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee1:	e8 21 fd ff ff       	call   800c07 <_pipeisclosed>
  800ee6:	83 c4 10             	add    $0x10,%esp
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800efb:	68 0e 1f 80 00       	push   $0x801f0e
  800f00:	ff 75 0c             	pushl  0xc(%ebp)
  800f03:	e8 c4 07 00 00       	call   8016cc <strcpy>
	return 0;
}
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f20:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f26:	eb 2d                	jmp    800f55 <devcons_write+0x46>
		m = n - tot;
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f2d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f30:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f35:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	53                   	push   %ebx
  800f3c:	03 45 0c             	add    0xc(%ebp),%eax
  800f3f:	50                   	push   %eax
  800f40:	57                   	push   %edi
  800f41:	e8 18 09 00 00       	call   80185e <memmove>
		sys_cputs(buf, m);
  800f46:	83 c4 08             	add    $0x8,%esp
  800f49:	53                   	push   %ebx
  800f4a:	57                   	push   %edi
  800f4b:	e8 5e f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f50:	01 de                	add    %ebx,%esi
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5a:	72 cc                	jb     800f28 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f73:	74 2a                	je     800f9f <devcons_read+0x3b>
  800f75:	eb 05                	jmp    800f7c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f77:	e8 cf f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f7c:	e8 4b f1 ff ff       	call   8000cc <sys_cgetc>
  800f81:	85 c0                	test   %eax,%eax
  800f83:	74 f2                	je     800f77 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 16                	js     800f9f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f89:	83 f8 04             	cmp    $0x4,%eax
  800f8c:	74 0c                	je     800f9a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f91:	88 02                	mov    %al,(%edx)
	return 1;
  800f93:	b8 01 00 00 00       	mov    $0x1,%eax
  800f98:	eb 05                	jmp    800f9f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fad:	6a 01                	push   $0x1
  800faf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	e8 f6 f0 ff ff       	call   8000ae <sys_cputs>
}
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <getchar>:

int
getchar(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fc3:	6a 01                	push   $0x1
  800fc5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 67 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 0f                	js     800fe6 <getchar+0x29>
		return r;
	if (r < 1)
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	7e 06                	jle    800fe1 <getchar+0x24>
		return -E_EOF;
	return c;
  800fdb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fdf:	eb 05                	jmp    800fe6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fe1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	ff 75 08             	pushl  0x8(%ebp)
  800ff5:	e8 d7 f3 ff ff       	call   8003d1 <fd_lookup>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 11                	js     801012 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801001:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801004:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80100a:	39 10                	cmp    %edx,(%eax)
  80100c:	0f 94 c0             	sete   %al
  80100f:	0f b6 c0             	movzbl %al,%eax
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <opencons>:

int
opencons(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101d:	50                   	push   %eax
  80101e:	e8 5f f3 ff ff       	call   800382 <fd_alloc>
  801023:	83 c4 10             	add    $0x10,%esp
		return r;
  801026:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 3e                	js     80106a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102c:	83 ec 04             	sub    $0x4,%esp
  80102f:	68 07 04 00 00       	push   $0x407
  801034:	ff 75 f4             	pushl  -0xc(%ebp)
  801037:	6a 00                	push   $0x0
  801039:	e8 2c f1 ff ff       	call   80016a <sys_page_alloc>
  80103e:	83 c4 10             	add    $0x10,%esp
		return r;
  801041:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801043:	85 c0                	test   %eax,%eax
  801045:	78 23                	js     80106a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801047:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80104d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801050:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	50                   	push   %eax
  801060:	e8 f6 f2 ff ff       	call   80035b <fd2num>
  801065:	89 c2                	mov    %eax,%edx
  801067:	83 c4 10             	add    $0x10,%esp
}
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801073:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801076:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80107c:	e8 ab f0 ff ff       	call   80012c <sys_getenvid>
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	ff 75 0c             	pushl  0xc(%ebp)
  801087:	ff 75 08             	pushl  0x8(%ebp)
  80108a:	56                   	push   %esi
  80108b:	50                   	push   %eax
  80108c:	68 1c 1f 80 00       	push   $0x801f1c
  801091:	e8 b1 00 00 00       	call   801147 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801096:	83 c4 18             	add    $0x18,%esp
  801099:	53                   	push   %ebx
  80109a:	ff 75 10             	pushl  0x10(%ebp)
  80109d:	e8 54 00 00 00       	call   8010f6 <vcprintf>
	cprintf("\n");
  8010a2:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  8010a9:	e8 99 00 00 00       	call   801147 <cprintf>
  8010ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b1:	cc                   	int3   
  8010b2:	eb fd                	jmp    8010b1 <_panic+0x43>

008010b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010be:	8b 13                	mov    (%ebx),%edx
  8010c0:	8d 42 01             	lea    0x1(%edx),%eax
  8010c3:	89 03                	mov    %eax,(%ebx)
  8010c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d1:	75 1a                	jne    8010ed <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010d3:	83 ec 08             	sub    $0x8,%esp
  8010d6:	68 ff 00 00 00       	push   $0xff
  8010db:	8d 43 08             	lea    0x8(%ebx),%eax
  8010de:	50                   	push   %eax
  8010df:	e8 ca ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ea:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801106:	00 00 00 
	b.cnt = 0;
  801109:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801110:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	ff 75 08             	pushl  0x8(%ebp)
  801119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	68 b4 10 80 00       	push   $0x8010b4
  801125:	e8 54 01 00 00       	call   80127e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112a:	83 c4 08             	add    $0x8,%esp
  80112d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801133:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	e8 6f ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80113f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80114d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801150:	50                   	push   %eax
  801151:	ff 75 08             	pushl  0x8(%ebp)
  801154:	e8 9d ff ff ff       	call   8010f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 1c             	sub    $0x1c,%esp
  801164:	89 c7                	mov    %eax,%edi
  801166:	89 d6                	mov    %edx,%esi
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801171:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801174:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80117f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801182:	39 d3                	cmp    %edx,%ebx
  801184:	72 05                	jb     80118b <printnum+0x30>
  801186:	39 45 10             	cmp    %eax,0x10(%ebp)
  801189:	77 45                	ja     8011d0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	ff 75 18             	pushl  0x18(%ebp)
  801191:	8b 45 14             	mov    0x14(%ebp),%eax
  801194:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801197:	53                   	push   %ebx
  801198:	ff 75 10             	pushl  0x10(%ebp)
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011aa:	e8 a1 09 00 00       	call   801b50 <__udivdi3>
  8011af:	83 c4 18             	add    $0x18,%esp
  8011b2:	52                   	push   %edx
  8011b3:	50                   	push   %eax
  8011b4:	89 f2                	mov    %esi,%edx
  8011b6:	89 f8                	mov    %edi,%eax
  8011b8:	e8 9e ff ff ff       	call   80115b <printnum>
  8011bd:	83 c4 20             	add    $0x20,%esp
  8011c0:	eb 18                	jmp    8011da <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	56                   	push   %esi
  8011c6:	ff 75 18             	pushl  0x18(%ebp)
  8011c9:	ff d7                	call   *%edi
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	eb 03                	jmp    8011d3 <printnum+0x78>
  8011d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011d3:	83 eb 01             	sub    $0x1,%ebx
  8011d6:	85 db                	test   %ebx,%ebx
  8011d8:	7f e8                	jg     8011c2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ed:	e8 8e 0a 00 00       	call   801c80 <__umoddi3>
  8011f2:	83 c4 14             	add    $0x14,%esp
  8011f5:	0f be 80 3f 1f 80 00 	movsbl 0x801f3f(%eax),%eax
  8011fc:	50                   	push   %eax
  8011fd:	ff d7                	call   *%edi
}
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80120d:	83 fa 01             	cmp    $0x1,%edx
  801210:	7e 0e                	jle    801220 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801212:	8b 10                	mov    (%eax),%edx
  801214:	8d 4a 08             	lea    0x8(%edx),%ecx
  801217:	89 08                	mov    %ecx,(%eax)
  801219:	8b 02                	mov    (%edx),%eax
  80121b:	8b 52 04             	mov    0x4(%edx),%edx
  80121e:	eb 22                	jmp    801242 <getuint+0x38>
	else if (lflag)
  801220:	85 d2                	test   %edx,%edx
  801222:	74 10                	je     801234 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801224:	8b 10                	mov    (%eax),%edx
  801226:	8d 4a 04             	lea    0x4(%edx),%ecx
  801229:	89 08                	mov    %ecx,(%eax)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	ba 00 00 00 00       	mov    $0x0,%edx
  801232:	eb 0e                	jmp    801242 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801234:	8b 10                	mov    (%eax),%edx
  801236:	8d 4a 04             	lea    0x4(%edx),%ecx
  801239:	89 08                	mov    %ecx,(%eax)
  80123b:	8b 02                	mov    (%edx),%eax
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80124a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80124e:	8b 10                	mov    (%eax),%edx
  801250:	3b 50 04             	cmp    0x4(%eax),%edx
  801253:	73 0a                	jae    80125f <sprintputch+0x1b>
		*b->buf++ = ch;
  801255:	8d 4a 01             	lea    0x1(%edx),%ecx
  801258:	89 08                	mov    %ecx,(%eax)
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	88 02                	mov    %al,(%edx)
}
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801267:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80126a:	50                   	push   %eax
  80126b:	ff 75 10             	pushl  0x10(%ebp)
  80126e:	ff 75 0c             	pushl  0xc(%ebp)
  801271:	ff 75 08             	pushl  0x8(%ebp)
  801274:	e8 05 00 00 00       	call   80127e <vprintfmt>
	va_end(ap);
}
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 2c             	sub    $0x2c,%esp
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801290:	eb 12                	jmp    8012a4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801292:	85 c0                	test   %eax,%eax
  801294:	0f 84 89 03 00 00    	je     801623 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	53                   	push   %ebx
  80129e:	50                   	push   %eax
  80129f:	ff d6                	call   *%esi
  8012a1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012a4:	83 c7 01             	add    $0x1,%edi
  8012a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ab:	83 f8 25             	cmp    $0x25,%eax
  8012ae:	75 e2                	jne    801292 <vprintfmt+0x14>
  8012b0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012c2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ce:	eb 07                	jmp    8012d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012d3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d7:	8d 47 01             	lea    0x1(%edi),%eax
  8012da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012dd:	0f b6 07             	movzbl (%edi),%eax
  8012e0:	0f b6 c8             	movzbl %al,%ecx
  8012e3:	83 e8 23             	sub    $0x23,%eax
  8012e6:	3c 55                	cmp    $0x55,%al
  8012e8:	0f 87 1a 03 00 00    	ja     801608 <vprintfmt+0x38a>
  8012ee:	0f b6 c0             	movzbl %al,%eax
  8012f1:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012ff:	eb d6                	jmp    8012d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
  801309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80130c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801313:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801316:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801319:	83 fa 09             	cmp    $0x9,%edx
  80131c:	77 39                	ja     801357 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80131e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801321:	eb e9                	jmp    80130c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	8d 48 04             	lea    0x4(%eax),%ecx
  801329:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80132c:	8b 00                	mov    (%eax),%eax
  80132e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801334:	eb 27                	jmp    80135d <vprintfmt+0xdf>
  801336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801339:	85 c0                	test   %eax,%eax
  80133b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801340:	0f 49 c8             	cmovns %eax,%ecx
  801343:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801349:	eb 8c                	jmp    8012d7 <vprintfmt+0x59>
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80134e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801355:	eb 80                	jmp    8012d7 <vprintfmt+0x59>
  801357:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80135d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801361:	0f 89 70 ff ff ff    	jns    8012d7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801367:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80136a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801374:	e9 5e ff ff ff       	jmp    8012d7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801379:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80137f:	e9 53 ff ff ff       	jmp    8012d7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801384:	8b 45 14             	mov    0x14(%ebp),%eax
  801387:	8d 50 04             	lea    0x4(%eax),%edx
  80138a:	89 55 14             	mov    %edx,0x14(%ebp)
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	53                   	push   %ebx
  801391:	ff 30                	pushl  (%eax)
  801393:	ff d6                	call   *%esi
			break;
  801395:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80139b:	e9 04 ff ff ff       	jmp    8012a4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a3:	8d 50 04             	lea    0x4(%eax),%edx
  8013a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a9:	8b 00                	mov    (%eax),%eax
  8013ab:	99                   	cltd   
  8013ac:	31 d0                	xor    %edx,%eax
  8013ae:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b0:	83 f8 0f             	cmp    $0xf,%eax
  8013b3:	7f 0b                	jg     8013c0 <vprintfmt+0x142>
  8013b5:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013bc:	85 d2                	test   %edx,%edx
  8013be:	75 18                	jne    8013d8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013c0:	50                   	push   %eax
  8013c1:	68 57 1f 80 00       	push   $0x801f57
  8013c6:	53                   	push   %ebx
  8013c7:	56                   	push   %esi
  8013c8:	e8 94 fe ff ff       	call   801261 <printfmt>
  8013cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013d3:	e9 cc fe ff ff       	jmp    8012a4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013d8:	52                   	push   %edx
  8013d9:	68 ce 1e 80 00       	push   $0x801ece
  8013de:	53                   	push   %ebx
  8013df:	56                   	push   %esi
  8013e0:	e8 7c fe ff ff       	call   801261 <printfmt>
  8013e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013eb:	e9 b4 fe ff ff       	jmp    8012a4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	8d 50 04             	lea    0x4(%eax),%edx
  8013f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013fb:	85 ff                	test   %edi,%edi
  8013fd:	b8 50 1f 80 00       	mov    $0x801f50,%eax
  801402:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801409:	0f 8e 94 00 00 00    	jle    8014a3 <vprintfmt+0x225>
  80140f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801413:	0f 84 98 00 00 00    	je     8014b1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	ff 75 d0             	pushl  -0x30(%ebp)
  80141f:	57                   	push   %edi
  801420:	e8 86 02 00 00       	call   8016ab <strnlen>
  801425:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801428:	29 c1                	sub    %eax,%ecx
  80142a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80142d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801430:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801437:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80143a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80143c:	eb 0f                	jmp    80144d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	53                   	push   %ebx
  801442:	ff 75 e0             	pushl  -0x20(%ebp)
  801445:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801447:	83 ef 01             	sub    $0x1,%edi
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 ff                	test   %edi,%edi
  80144f:	7f ed                	jg     80143e <vprintfmt+0x1c0>
  801451:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801454:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801457:	85 c9                	test   %ecx,%ecx
  801459:	b8 00 00 00 00       	mov    $0x0,%eax
  80145e:	0f 49 c1             	cmovns %ecx,%eax
  801461:	29 c1                	sub    %eax,%ecx
  801463:	89 75 08             	mov    %esi,0x8(%ebp)
  801466:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801469:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146c:	89 cb                	mov    %ecx,%ebx
  80146e:	eb 4d                	jmp    8014bd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801470:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801474:	74 1b                	je     801491 <vprintfmt+0x213>
  801476:	0f be c0             	movsbl %al,%eax
  801479:	83 e8 20             	sub    $0x20,%eax
  80147c:	83 f8 5e             	cmp    $0x5e,%eax
  80147f:	76 10                	jbe    801491 <vprintfmt+0x213>
					putch('?', putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	6a 3f                	push   $0x3f
  801489:	ff 55 08             	call   *0x8(%ebp)
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	eb 0d                	jmp    80149e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	52                   	push   %edx
  801498:	ff 55 08             	call   *0x8(%ebp)
  80149b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80149e:	83 eb 01             	sub    $0x1,%ebx
  8014a1:	eb 1a                	jmp    8014bd <vprintfmt+0x23f>
  8014a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014af:	eb 0c                	jmp    8014bd <vprintfmt+0x23f>
  8014b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014bd:	83 c7 01             	add    $0x1,%edi
  8014c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c4:	0f be d0             	movsbl %al,%edx
  8014c7:	85 d2                	test   %edx,%edx
  8014c9:	74 23                	je     8014ee <vprintfmt+0x270>
  8014cb:	85 f6                	test   %esi,%esi
  8014cd:	78 a1                	js     801470 <vprintfmt+0x1f2>
  8014cf:	83 ee 01             	sub    $0x1,%esi
  8014d2:	79 9c                	jns    801470 <vprintfmt+0x1f2>
  8014d4:	89 df                	mov    %ebx,%edi
  8014d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014dc:	eb 18                	jmp    8014f6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	6a 20                	push   $0x20
  8014e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014e6:	83 ef 01             	sub    $0x1,%edi
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	eb 08                	jmp    8014f6 <vprintfmt+0x278>
  8014ee:	89 df                	mov    %ebx,%edi
  8014f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f6:	85 ff                	test   %edi,%edi
  8014f8:	7f e4                	jg     8014de <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014fd:	e9 a2 fd ff ff       	jmp    8012a4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801502:	83 fa 01             	cmp    $0x1,%edx
  801505:	7e 16                	jle    80151d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8d 50 08             	lea    0x8(%eax),%edx
  80150d:	89 55 14             	mov    %edx,0x14(%ebp)
  801510:	8b 50 04             	mov    0x4(%eax),%edx
  801513:	8b 00                	mov    (%eax),%eax
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80151b:	eb 32                	jmp    80154f <vprintfmt+0x2d1>
	else if (lflag)
  80151d:	85 d2                	test   %edx,%edx
  80151f:	74 18                	je     801539 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801521:	8b 45 14             	mov    0x14(%ebp),%eax
  801524:	8d 50 04             	lea    0x4(%eax),%edx
  801527:	89 55 14             	mov    %edx,0x14(%ebp)
  80152a:	8b 00                	mov    (%eax),%eax
  80152c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152f:	89 c1                	mov    %eax,%ecx
  801531:	c1 f9 1f             	sar    $0x1f,%ecx
  801534:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801537:	eb 16                	jmp    80154f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8d 50 04             	lea    0x4(%eax),%edx
  80153f:	89 55 14             	mov    %edx,0x14(%ebp)
  801542:	8b 00                	mov    (%eax),%eax
  801544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801547:	89 c1                	mov    %eax,%ecx
  801549:	c1 f9 1f             	sar    $0x1f,%ecx
  80154c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80154f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801552:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801555:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80155a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80155e:	79 74                	jns    8015d4 <vprintfmt+0x356>
				putch('-', putdat);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	53                   	push   %ebx
  801564:	6a 2d                	push   $0x2d
  801566:	ff d6                	call   *%esi
				num = -(long long) num;
  801568:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80156b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80156e:	f7 d8                	neg    %eax
  801570:	83 d2 00             	adc    $0x0,%edx
  801573:	f7 da                	neg    %edx
  801575:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801578:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80157d:	eb 55                	jmp    8015d4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80157f:	8d 45 14             	lea    0x14(%ebp),%eax
  801582:	e8 83 fc ff ff       	call   80120a <getuint>
			base = 10;
  801587:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80158c:	eb 46                	jmp    8015d4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80158e:	8d 45 14             	lea    0x14(%ebp),%eax
  801591:	e8 74 fc ff ff       	call   80120a <getuint>
                        base = 8;
  801596:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80159b:	eb 37                	jmp    8015d4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 30                	push   $0x30
  8015a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	6a 78                	push   $0x78
  8015ab:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b0:	8d 50 04             	lea    0x4(%eax),%edx
  8015b3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b6:	8b 00                	mov    (%eax),%eax
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015c5:	eb 0d                	jmp    8015d4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ca:	e8 3b fc ff ff       	call   80120a <getuint>
			base = 16;
  8015cf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015db:	57                   	push   %edi
  8015dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015df:	51                   	push   %ecx
  8015e0:	52                   	push   %edx
  8015e1:	50                   	push   %eax
  8015e2:	89 da                	mov    %ebx,%edx
  8015e4:	89 f0                	mov    %esi,%eax
  8015e6:	e8 70 fb ff ff       	call   80115b <printnum>
			break;
  8015eb:	83 c4 20             	add    $0x20,%esp
  8015ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015f1:	e9 ae fc ff ff       	jmp    8012a4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	51                   	push   %ecx
  8015fb:	ff d6                	call   *%esi
			break;
  8015fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801603:	e9 9c fc ff ff       	jmp    8012a4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	53                   	push   %ebx
  80160c:	6a 25                	push   $0x25
  80160e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 03                	jmp    801618 <vprintfmt+0x39a>
  801615:	83 ef 01             	sub    $0x1,%edi
  801618:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80161c:	75 f7                	jne    801615 <vprintfmt+0x397>
  80161e:	e9 81 fc ff ff       	jmp    8012a4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 18             	sub    $0x18,%esp
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801637:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80163a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80163e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801641:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801648:	85 c0                	test   %eax,%eax
  80164a:	74 26                	je     801672 <vsnprintf+0x47>
  80164c:	85 d2                	test   %edx,%edx
  80164e:	7e 22                	jle    801672 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801650:	ff 75 14             	pushl  0x14(%ebp)
  801653:	ff 75 10             	pushl  0x10(%ebp)
  801656:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	68 44 12 80 00       	push   $0x801244
  80165f:	e8 1a fc ff ff       	call   80127e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801664:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801667:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80166a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 05                	jmp    801677 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801672:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80167f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801682:	50                   	push   %eax
  801683:	ff 75 10             	pushl  0x10(%ebp)
  801686:	ff 75 0c             	pushl  0xc(%ebp)
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	e8 9a ff ff ff       	call   80162b <vsnprintf>
	va_end(ap);

	return rc;
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
  80169e:	eb 03                	jmp    8016a3 <strlen+0x10>
		n++;
  8016a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a7:	75 f7                	jne    8016a0 <strlen+0xd>
		n++;
	return n;
}
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	eb 03                	jmp    8016be <strnlen+0x13>
		n++;
  8016bb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016be:	39 c2                	cmp    %eax,%edx
  8016c0:	74 08                	je     8016ca <strnlen+0x1f>
  8016c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016c6:	75 f3                	jne    8016bb <strnlen+0x10>
  8016c8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	83 c2 01             	add    $0x1,%edx
  8016db:	83 c1 01             	add    $0x1,%ecx
  8016de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016e5:	84 db                	test   %bl,%bl
  8016e7:	75 ef                	jne    8016d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e9:	5b                   	pop    %ebx
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	53                   	push   %ebx
  8016f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016f3:	53                   	push   %ebx
  8016f4:	e8 9a ff ff ff       	call   801693 <strlen>
  8016f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016fc:	ff 75 0c             	pushl  0xc(%ebp)
  8016ff:	01 d8                	add    %ebx,%eax
  801701:	50                   	push   %eax
  801702:	e8 c5 ff ff ff       	call   8016cc <strcpy>
	return dst;
}
  801707:	89 d8                	mov    %ebx,%eax
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	8b 75 08             	mov    0x8(%ebp),%esi
  801716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801719:	89 f3                	mov    %esi,%ebx
  80171b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171e:	89 f2                	mov    %esi,%edx
  801720:	eb 0f                	jmp    801731 <strncpy+0x23>
		*dst++ = *src;
  801722:	83 c2 01             	add    $0x1,%edx
  801725:	0f b6 01             	movzbl (%ecx),%eax
  801728:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80172b:	80 39 01             	cmpb   $0x1,(%ecx)
  80172e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801731:	39 da                	cmp    %ebx,%edx
  801733:	75 ed                	jne    801722 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801735:	89 f0                	mov    %esi,%eax
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	8b 75 08             	mov    0x8(%ebp),%esi
  801743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801746:	8b 55 10             	mov    0x10(%ebp),%edx
  801749:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174b:	85 d2                	test   %edx,%edx
  80174d:	74 21                	je     801770 <strlcpy+0x35>
  80174f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801753:	89 f2                	mov    %esi,%edx
  801755:	eb 09                	jmp    801760 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801757:	83 c2 01             	add    $0x1,%edx
  80175a:	83 c1 01             	add    $0x1,%ecx
  80175d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801760:	39 c2                	cmp    %eax,%edx
  801762:	74 09                	je     80176d <strlcpy+0x32>
  801764:	0f b6 19             	movzbl (%ecx),%ebx
  801767:	84 db                	test   %bl,%bl
  801769:	75 ec                	jne    801757 <strlcpy+0x1c>
  80176b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80176d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801770:	29 f0                	sub    %esi,%eax
}
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80177f:	eb 06                	jmp    801787 <strcmp+0x11>
		p++, q++;
  801781:	83 c1 01             	add    $0x1,%ecx
  801784:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801787:	0f b6 01             	movzbl (%ecx),%eax
  80178a:	84 c0                	test   %al,%al
  80178c:	74 04                	je     801792 <strcmp+0x1c>
  80178e:	3a 02                	cmp    (%edx),%al
  801790:	74 ef                	je     801781 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801792:	0f b6 c0             	movzbl %al,%eax
  801795:	0f b6 12             	movzbl (%edx),%edx
  801798:	29 d0                	sub    %edx,%eax
}
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	53                   	push   %ebx
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ab:	eb 06                	jmp    8017b3 <strncmp+0x17>
		n--, p++, q++;
  8017ad:	83 c0 01             	add    $0x1,%eax
  8017b0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017b3:	39 d8                	cmp    %ebx,%eax
  8017b5:	74 15                	je     8017cc <strncmp+0x30>
  8017b7:	0f b6 08             	movzbl (%eax),%ecx
  8017ba:	84 c9                	test   %cl,%cl
  8017bc:	74 04                	je     8017c2 <strncmp+0x26>
  8017be:	3a 0a                	cmp    (%edx),%cl
  8017c0:	74 eb                	je     8017ad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c2:	0f b6 00             	movzbl (%eax),%eax
  8017c5:	0f b6 12             	movzbl (%edx),%edx
  8017c8:	29 d0                	sub    %edx,%eax
  8017ca:	eb 05                	jmp    8017d1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017d1:	5b                   	pop    %ebx
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017de:	eb 07                	jmp    8017e7 <strchr+0x13>
		if (*s == c)
  8017e0:	38 ca                	cmp    %cl,%dl
  8017e2:	74 0f                	je     8017f3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e4:	83 c0 01             	add    $0x1,%eax
  8017e7:	0f b6 10             	movzbl (%eax),%edx
  8017ea:	84 d2                	test   %dl,%dl
  8017ec:	75 f2                	jne    8017e0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ff:	eb 03                	jmp    801804 <strfind+0xf>
  801801:	83 c0 01             	add    $0x1,%eax
  801804:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801807:	38 ca                	cmp    %cl,%dl
  801809:	74 04                	je     80180f <strfind+0x1a>
  80180b:	84 d2                	test   %dl,%dl
  80180d:	75 f2                	jne    801801 <strfind+0xc>
			break;
	return (char *) s;
}
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	57                   	push   %edi
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	8b 7d 08             	mov    0x8(%ebp),%edi
  80181a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80181d:	85 c9                	test   %ecx,%ecx
  80181f:	74 36                	je     801857 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801821:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801827:	75 28                	jne    801851 <memset+0x40>
  801829:	f6 c1 03             	test   $0x3,%cl
  80182c:	75 23                	jne    801851 <memset+0x40>
		c &= 0xFF;
  80182e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801832:	89 d3                	mov    %edx,%ebx
  801834:	c1 e3 08             	shl    $0x8,%ebx
  801837:	89 d6                	mov    %edx,%esi
  801839:	c1 e6 18             	shl    $0x18,%esi
  80183c:	89 d0                	mov    %edx,%eax
  80183e:	c1 e0 10             	shl    $0x10,%eax
  801841:	09 f0                	or     %esi,%eax
  801843:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801845:	89 d8                	mov    %ebx,%eax
  801847:	09 d0                	or     %edx,%eax
  801849:	c1 e9 02             	shr    $0x2,%ecx
  80184c:	fc                   	cld    
  80184d:	f3 ab                	rep stos %eax,%es:(%edi)
  80184f:	eb 06                	jmp    801857 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	fc                   	cld    
  801855:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801857:	89 f8                	mov    %edi,%eax
  801859:	5b                   	pop    %ebx
  80185a:	5e                   	pop    %esi
  80185b:	5f                   	pop    %edi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 75 0c             	mov    0xc(%ebp),%esi
  801869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80186c:	39 c6                	cmp    %eax,%esi
  80186e:	73 35                	jae    8018a5 <memmove+0x47>
  801870:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801873:	39 d0                	cmp    %edx,%eax
  801875:	73 2e                	jae    8018a5 <memmove+0x47>
		s += n;
		d += n;
  801877:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187a:	89 d6                	mov    %edx,%esi
  80187c:	09 fe                	or     %edi,%esi
  80187e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801884:	75 13                	jne    801899 <memmove+0x3b>
  801886:	f6 c1 03             	test   $0x3,%cl
  801889:	75 0e                	jne    801899 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80188b:	83 ef 04             	sub    $0x4,%edi
  80188e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801891:	c1 e9 02             	shr    $0x2,%ecx
  801894:	fd                   	std    
  801895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801897:	eb 09                	jmp    8018a2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801899:	83 ef 01             	sub    $0x1,%edi
  80189c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80189f:	fd                   	std    
  8018a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a2:	fc                   	cld    
  8018a3:	eb 1d                	jmp    8018c2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a5:	89 f2                	mov    %esi,%edx
  8018a7:	09 c2                	or     %eax,%edx
  8018a9:	f6 c2 03             	test   $0x3,%dl
  8018ac:	75 0f                	jne    8018bd <memmove+0x5f>
  8018ae:	f6 c1 03             	test   $0x3,%cl
  8018b1:	75 0a                	jne    8018bd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018b3:	c1 e9 02             	shr    $0x2,%ecx
  8018b6:	89 c7                	mov    %eax,%edi
  8018b8:	fc                   	cld    
  8018b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bb:	eb 05                	jmp    8018c2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018bd:	89 c7                	mov    %eax,%edi
  8018bf:	fc                   	cld    
  8018c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c2:	5e                   	pop    %esi
  8018c3:	5f                   	pop    %edi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c9:	ff 75 10             	pushl  0x10(%ebp)
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	ff 75 08             	pushl  0x8(%ebp)
  8018d2:	e8 87 ff ff ff       	call   80185e <memmove>
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e4:	89 c6                	mov    %eax,%esi
  8018e6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e9:	eb 1a                	jmp    801905 <memcmp+0x2c>
		if (*s1 != *s2)
  8018eb:	0f b6 08             	movzbl (%eax),%ecx
  8018ee:	0f b6 1a             	movzbl (%edx),%ebx
  8018f1:	38 d9                	cmp    %bl,%cl
  8018f3:	74 0a                	je     8018ff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018f5:	0f b6 c1             	movzbl %cl,%eax
  8018f8:	0f b6 db             	movzbl %bl,%ebx
  8018fb:	29 d8                	sub    %ebx,%eax
  8018fd:	eb 0f                	jmp    80190e <memcmp+0x35>
		s1++, s2++;
  8018ff:	83 c0 01             	add    $0x1,%eax
  801902:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801905:	39 f0                	cmp    %esi,%eax
  801907:	75 e2                	jne    8018eb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	53                   	push   %ebx
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801919:	89 c1                	mov    %eax,%ecx
  80191b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80191e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801922:	eb 0a                	jmp    80192e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801924:	0f b6 10             	movzbl (%eax),%edx
  801927:	39 da                	cmp    %ebx,%edx
  801929:	74 07                	je     801932 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192b:	83 c0 01             	add    $0x1,%eax
  80192e:	39 c8                	cmp    %ecx,%eax
  801930:	72 f2                	jb     801924 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801932:	5b                   	pop    %ebx
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	57                   	push   %edi
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801941:	eb 03                	jmp    801946 <strtol+0x11>
		s++;
  801943:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801946:	0f b6 01             	movzbl (%ecx),%eax
  801949:	3c 20                	cmp    $0x20,%al
  80194b:	74 f6                	je     801943 <strtol+0xe>
  80194d:	3c 09                	cmp    $0x9,%al
  80194f:	74 f2                	je     801943 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801951:	3c 2b                	cmp    $0x2b,%al
  801953:	75 0a                	jne    80195f <strtol+0x2a>
		s++;
  801955:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801958:	bf 00 00 00 00       	mov    $0x0,%edi
  80195d:	eb 11                	jmp    801970 <strtol+0x3b>
  80195f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801964:	3c 2d                	cmp    $0x2d,%al
  801966:	75 08                	jne    801970 <strtol+0x3b>
		s++, neg = 1;
  801968:	83 c1 01             	add    $0x1,%ecx
  80196b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801970:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801976:	75 15                	jne    80198d <strtol+0x58>
  801978:	80 39 30             	cmpb   $0x30,(%ecx)
  80197b:	75 10                	jne    80198d <strtol+0x58>
  80197d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801981:	75 7c                	jne    8019ff <strtol+0xca>
		s += 2, base = 16;
  801983:	83 c1 02             	add    $0x2,%ecx
  801986:	bb 10 00 00 00       	mov    $0x10,%ebx
  80198b:	eb 16                	jmp    8019a3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80198d:	85 db                	test   %ebx,%ebx
  80198f:	75 12                	jne    8019a3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801991:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801996:	80 39 30             	cmpb   $0x30,(%ecx)
  801999:	75 08                	jne    8019a3 <strtol+0x6e>
		s++, base = 8;
  80199b:	83 c1 01             	add    $0x1,%ecx
  80199e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ab:	0f b6 11             	movzbl (%ecx),%edx
  8019ae:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019b1:	89 f3                	mov    %esi,%ebx
  8019b3:	80 fb 09             	cmp    $0x9,%bl
  8019b6:	77 08                	ja     8019c0 <strtol+0x8b>
			dig = *s - '0';
  8019b8:	0f be d2             	movsbl %dl,%edx
  8019bb:	83 ea 30             	sub    $0x30,%edx
  8019be:	eb 22                	jmp    8019e2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019c0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019c3:	89 f3                	mov    %esi,%ebx
  8019c5:	80 fb 19             	cmp    $0x19,%bl
  8019c8:	77 08                	ja     8019d2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019ca:	0f be d2             	movsbl %dl,%edx
  8019cd:	83 ea 57             	sub    $0x57,%edx
  8019d0:	eb 10                	jmp    8019e2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019d2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019d5:	89 f3                	mov    %esi,%ebx
  8019d7:	80 fb 19             	cmp    $0x19,%bl
  8019da:	77 16                	ja     8019f2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019dc:	0f be d2             	movsbl %dl,%edx
  8019df:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019e2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e5:	7d 0b                	jge    8019f2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019e7:	83 c1 01             	add    $0x1,%ecx
  8019ea:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019f0:	eb b9                	jmp    8019ab <strtol+0x76>

	if (endptr)
  8019f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f6:	74 0d                	je     801a05 <strtol+0xd0>
		*endptr = (char *) s;
  8019f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019fb:	89 0e                	mov    %ecx,(%esi)
  8019fd:	eb 06                	jmp    801a05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ff:	85 db                	test   %ebx,%ebx
  801a01:	74 98                	je     80199b <strtol+0x66>
  801a03:	eb 9e                	jmp    8019a3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	f7 da                	neg    %edx
  801a09:	85 ff                	test   %edi,%edi
  801a0b:	0f 45 c2             	cmovne %edx,%eax
}
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a21:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a23:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a28:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	50                   	push   %eax
  801a2f:	e8 e6 e8 ff ff       	call   80031a <sys_ipc_recv>

	if (r < 0) {
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	85 c0                	test   %eax,%eax
  801a39:	79 16                	jns    801a51 <ipc_recv+0x3e>
		if (from_env_store)
  801a3b:	85 f6                	test   %esi,%esi
  801a3d:	74 06                	je     801a45 <ipc_recv+0x32>
			*from_env_store = 0;
  801a3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a45:	85 db                	test   %ebx,%ebx
  801a47:	74 2c                	je     801a75 <ipc_recv+0x62>
			*perm_store = 0;
  801a49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a4f:	eb 24                	jmp    801a75 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a51:	85 f6                	test   %esi,%esi
  801a53:	74 0a                	je     801a5f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a55:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5a:	8b 40 74             	mov    0x74(%eax),%eax
  801a5d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a5f:	85 db                	test   %ebx,%ebx
  801a61:	74 0a                	je     801a6d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a63:	a1 04 40 80 00       	mov    0x804004,%eax
  801a68:	8b 40 78             	mov    0x78(%eax),%eax
  801a6b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a72:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a8e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a90:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a95:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a98:	ff 75 14             	pushl  0x14(%ebp)
  801a9b:	53                   	push   %ebx
  801a9c:	56                   	push   %esi
  801a9d:	57                   	push   %edi
  801a9e:	e8 54 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa9:	75 07                	jne    801ab2 <ipc_send+0x36>
			sys_yield();
  801aab:	e8 9b e6 ff ff       	call   80014b <sys_yield>
  801ab0:	eb e6                	jmp    801a98 <ipc_send+0x1c>
		} else if (r < 0) {
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	79 12                	jns    801ac8 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ab6:	50                   	push   %eax
  801ab7:	68 40 22 80 00       	push   $0x802240
  801abc:	6a 51                	push   $0x51
  801abe:	68 4d 22 80 00       	push   $0x80224d
  801ac3:	e8 a6 f5 ff ff       	call   80106e <_panic>
		}
	}
}
  801ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801adb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ade:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae4:	8b 52 50             	mov    0x50(%edx),%edx
  801ae7:	39 ca                	cmp    %ecx,%edx
  801ae9:	75 0d                	jne    801af8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aeb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af3:	8b 40 48             	mov    0x48(%eax),%eax
  801af6:	eb 0f                	jmp    801b07 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af8:	83 c0 01             	add    $0x1,%eax
  801afb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b00:	75 d9                	jne    801adb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0f:	89 d0                	mov    %edx,%eax
  801b11:	c1 e8 16             	shr    $0x16,%eax
  801b14:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b20:	f6 c1 01             	test   $0x1,%cl
  801b23:	74 1d                	je     801b42 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2f:	f6 c2 01             	test   $0x1,%dl
  801b32:	74 0e                	je     801b42 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b34:	c1 ea 0c             	shr    $0xc,%edx
  801b37:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3e:	ef 
  801b3f:	0f b7 c0             	movzwl %ax,%eax
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    
  801b44:	66 90                	xchg   %ax,%ax
  801b46:	66 90                	xchg   %ax,%ax
  801b48:	66 90                	xchg   %ax,%ax
  801b4a:	66 90                	xchg   %ax,%ax
  801b4c:	66 90                	xchg   %ax,%ax
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b67:	85 f6                	test   %esi,%esi
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 ca                	mov    %ecx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	75 3d                	jne    801bb0 <__udivdi3+0x60>
  801b73:	39 cf                	cmp    %ecx,%edi
  801b75:	0f 87 c5 00 00 00    	ja     801c40 <__udivdi3+0xf0>
  801b7b:	85 ff                	test   %edi,%edi
  801b7d:	89 fd                	mov    %edi,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f7                	div    %edi
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	89 cf                	mov    %ecx,%edi
  801b98:	f7 f5                	div    %ebp
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	89 fa                	mov    %edi,%edx
  801ba0:	83 c4 1c             	add    $0x1c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	90                   	nop
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 ce                	cmp    %ecx,%esi
  801bb2:	77 74                	ja     801c28 <__udivdi3+0xd8>
  801bb4:	0f bd fe             	bsr    %esi,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0x108>
  801bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	89 c5                	mov    %eax,%ebp
  801bc9:	29 fb                	sub    %edi,%ebx
  801bcb:	d3 e6                	shl    %cl,%esi
  801bcd:	89 d9                	mov    %ebx,%ecx
  801bcf:	d3 ed                	shr    %cl,%ebp
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	09 ee                	or     %ebp,%esi
  801bd7:	89 d9                	mov    %ebx,%ecx
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 d5                	mov    %edx,%ebp
  801bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801be3:	d3 ed                	shr    %cl,%ebp
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e2                	shl    %cl,%edx
  801be9:	89 d9                	mov    %ebx,%ecx
  801beb:	d3 e8                	shr    %cl,%eax
  801bed:	09 c2                	or     %eax,%edx
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	89 ea                	mov    %ebp,%edx
  801bf3:	f7 f6                	div    %esi
  801bf5:	89 d5                	mov    %edx,%ebp
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	f7 64 24 0c          	mull   0xc(%esp)
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	72 10                	jb     801c11 <__udivdi3+0xc1>
  801c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e6                	shl    %cl,%esi
  801c09:	39 c6                	cmp    %eax,%esi
  801c0b:	73 07                	jae    801c14 <__udivdi3+0xc4>
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	75 03                	jne    801c14 <__udivdi3+0xc4>
  801c11:	83 eb 01             	sub    $0x1,%ebx
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	89 fa                	mov    %edi,%edx
  801c1a:	83 c4 1c             	add    $0x1c,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    
  801c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c28:	31 ff                	xor    %edi,%edi
  801c2a:	31 db                	xor    %ebx,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	f7 f7                	div    %edi
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	89 fa                	mov    %edi,%edx
  801c4c:	83 c4 1c             	add    $0x1c,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 ce                	cmp    %ecx,%esi
  801c5a:	72 0c                	jb     801c68 <__udivdi3+0x118>
  801c5c:	31 db                	xor    %ebx,%ebx
  801c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c62:	0f 87 34 ff ff ff    	ja     801b9c <__udivdi3+0x4c>
  801c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c6d:	e9 2a ff ff ff       	jmp    801b9c <__udivdi3+0x4c>
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 d2                	test   %edx,%edx
  801c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca1:	89 f3                	mov    %esi,%ebx
  801ca3:	89 3c 24             	mov    %edi,(%esp)
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	75 1c                	jne    801cc8 <__umoddi3+0x48>
  801cac:	39 f7                	cmp    %esi,%edi
  801cae:	76 50                	jbe    801d00 <__umoddi3+0x80>
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	f7 f7                	div    %edi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	31 d2                	xor    %edx,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	77 52                	ja     801d20 <__umoddi3+0xa0>
  801cce:	0f bd ea             	bsr    %edx,%ebp
  801cd1:	83 f5 1f             	xor    $0x1f,%ebp
  801cd4:	75 5a                	jne    801d30 <__umoddi3+0xb0>
  801cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	39 0c 24             	cmp    %ecx,(%esp)
  801ce3:	0f 86 d7 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	85 ff                	test   %edi,%edi
  801d02:	89 fd                	mov    %edi,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	eb 99                	jmp    801cb8 <__umoddi3+0x38>
  801d1f:	90                   	nop
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	8b 34 24             	mov    (%esp),%esi
  801d33:	bf 20 00 00 00       	mov    $0x20,%edi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	29 ef                	sub    %ebp,%edi
  801d3c:	d3 e0                	shl    %cl,%eax
  801d3e:	89 f9                	mov    %edi,%ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	d3 ea                	shr    %cl,%edx
  801d44:	89 e9                	mov    %ebp,%ecx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 14 24             	mov    %edx,(%esp)
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	d3 e2                	shl    %cl,%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
  801d61:	d3 e3                	shl    %cl,%ebx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d8                	or     %ebx,%eax
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	f7 34 24             	divl   (%esp)
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	d3 e3                	shl    %cl,%ebx
  801d78:	f7 64 24 04          	mull   0x4(%esp)
  801d7c:	39 d6                	cmp    %edx,%esi
  801d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	72 08                	jb     801d90 <__umoddi3+0x110>
  801d88:	75 11                	jne    801d9b <__umoddi3+0x11b>
  801d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d8e:	73 0b                	jae    801d9b <__umoddi3+0x11b>
  801d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d94:	1b 14 24             	sbb    (%esp),%edx
  801d97:	89 d1                	mov    %edx,%ecx
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
  801da1:	19 ce                	sbb    %ecx,%esi
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 ee                	shr    %cl,%esi
  801db1:	09 d0                	or     %edx,%eax
  801db3:	89 f2                	mov    %esi,%edx
  801db5:	83 c4 1c             	add    $0x1c,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 f9                	sub    %edi,%ecx
  801dc2:	19 d6                	sbb    %edx,%esi
  801dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dcc:	e9 18 ff ff ff       	jmp    801ce9 <__umoddi3+0x69>
