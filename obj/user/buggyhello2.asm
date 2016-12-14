
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
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80009a:	e8 6b 05 00 00       	call   80060a <close_all>
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
  800113:	68 38 23 80 00       	push   $0x802338
  800118:	6a 23                	push   $0x23
  80011a:	68 55 23 80 00       	push   $0x802355
  80011f:	e8 95 14 00 00       	call   8015b9 <_panic>

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
  800194:	68 38 23 80 00       	push   $0x802338
  800199:	6a 23                	push   $0x23
  80019b:	68 55 23 80 00       	push   $0x802355
  8001a0:	e8 14 14 00 00       	call   8015b9 <_panic>

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
  8001d6:	68 38 23 80 00       	push   $0x802338
  8001db:	6a 23                	push   $0x23
  8001dd:	68 55 23 80 00       	push   $0x802355
  8001e2:	e8 d2 13 00 00       	call   8015b9 <_panic>

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
  800218:	68 38 23 80 00       	push   $0x802338
  80021d:	6a 23                	push   $0x23
  80021f:	68 55 23 80 00       	push   $0x802355
  800224:	e8 90 13 00 00       	call   8015b9 <_panic>

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
  80025a:	68 38 23 80 00       	push   $0x802338
  80025f:	6a 23                	push   $0x23
  800261:	68 55 23 80 00       	push   $0x802355
  800266:	e8 4e 13 00 00       	call   8015b9 <_panic>

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
  80029c:	68 38 23 80 00       	push   $0x802338
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 55 23 80 00       	push   $0x802355
  8002a8:	e8 0c 13 00 00       	call   8015b9 <_panic>

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
  8002de:	68 38 23 80 00       	push   $0x802338
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 55 23 80 00       	push   $0x802355
  8002ea:	e8 ca 12 00 00       	call   8015b9 <_panic>

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
  800342:	68 38 23 80 00       	push   $0x802338
  800347:	6a 23                	push   $0x23
  800349:	68 55 23 80 00       	push   $0x802355
  80034e:	e8 66 12 00 00       	call   8015b9 <_panic>

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

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800383:	bb 00 00 00 00       	mov    $0x0,%ebx
  800388:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 df                	mov    %ebx,%edi
  800395:	89 de                	mov    %ebx,%esi
  800397:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 17                	jle    8003b4 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	83 ec 0c             	sub    $0xc,%esp
  8003a0:	50                   	push   %eax
  8003a1:	6a 0f                	push   $0xf
  8003a3:	68 38 23 80 00       	push   $0x802338
  8003a8:	6a 23                	push   $0x23
  8003aa:	68 55 23 80 00       	push   $0x802355
  8003af:	e8 05 12 00 00       	call   8015b9 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8003cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d5:	89 df                	mov    %ebx,%edi
  8003d7:	89 de                	mov    %ebx,%esi
  8003d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	7e 17                	jle    8003f6 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003df:	83 ec 0c             	sub    $0xc,%esp
  8003e2:	50                   	push   %eax
  8003e3:	6a 10                	push   $0x10
  8003e5:	68 38 23 80 00       	push   $0x802338
  8003ea:	6a 23                	push   $0x23
  8003ec:	68 55 23 80 00       	push   $0x802355
  8003f1:	e8 c3 11 00 00       	call   8015b9 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8003f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f9:	5b                   	pop    %ebx
  8003fa:	5e                   	pop    %esi
  8003fb:	5f                   	pop    %edi
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040c:	b8 11 00 00 00       	mov    $0x11,%eax
  800411:	8b 55 08             	mov    0x8(%ebp),%edx
  800414:	89 cb                	mov    %ecx,%ebx
  800416:	89 cf                	mov    %ecx,%edi
  800418:	89 ce                	mov    %ecx,%esi
  80041a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80041c:	85 c0                	test   %eax,%eax
  80041e:	7e 17                	jle    800437 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800420:	83 ec 0c             	sub    $0xc,%esp
  800423:	50                   	push   %eax
  800424:	6a 11                	push   $0x11
  800426:	68 38 23 80 00       	push   $0x802338
  80042b:	6a 23                	push   $0x23
  80042d:	68 55 23 80 00       	push   $0x802355
  800432:	e8 82 11 00 00       	call   8015b9 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800437:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043a:	5b                   	pop    %ebx
  80043b:	5e                   	pop    %esi
  80043c:	5f                   	pop    %edi
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	05 00 00 00 30       	add    $0x30000000,%eax
  80044a:	c1 e8 0c             	shr    $0xc,%eax
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800452:	8b 45 08             	mov    0x8(%ebp),%eax
  800455:	05 00 00 00 30       	add    $0x30000000,%eax
  80045a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80045f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800471:	89 c2                	mov    %eax,%edx
  800473:	c1 ea 16             	shr    $0x16,%edx
  800476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047d:	f6 c2 01             	test   $0x1,%dl
  800480:	74 11                	je     800493 <fd_alloc+0x2d>
  800482:	89 c2                	mov    %eax,%edx
  800484:	c1 ea 0c             	shr    $0xc,%edx
  800487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048e:	f6 c2 01             	test   $0x1,%dl
  800491:	75 09                	jne    80049c <fd_alloc+0x36>
			*fd_store = fd;
  800493:	89 01                	mov    %eax,(%ecx)
			return 0;
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	eb 17                	jmp    8004b3 <fd_alloc+0x4d>
  80049c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004a6:	75 c9                	jne    800471 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004a8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8004ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004b3:	5d                   	pop    %ebp
  8004b4:	c3                   	ret    

008004b5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004bb:	83 f8 1f             	cmp    $0x1f,%eax
  8004be:	77 36                	ja     8004f6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004c0:	c1 e0 0c             	shl    $0xc,%eax
  8004c3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004c8:	89 c2                	mov    %eax,%edx
  8004ca:	c1 ea 16             	shr    $0x16,%edx
  8004cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004d4:	f6 c2 01             	test   $0x1,%dl
  8004d7:	74 24                	je     8004fd <fd_lookup+0x48>
  8004d9:	89 c2                	mov    %eax,%edx
  8004db:	c1 ea 0c             	shr    $0xc,%edx
  8004de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004e5:	f6 c2 01             	test   $0x1,%dl
  8004e8:	74 1a                	je     800504 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ed:	89 02                	mov    %eax,(%edx)
	return 0;
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	eb 13                	jmp    800509 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004fb:	eb 0c                	jmp    800509 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800502:	eb 05                	jmp    800509 <fd_lookup+0x54>
  800504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800514:	ba e0 23 80 00       	mov    $0x8023e0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800519:	eb 13                	jmp    80052e <dev_lookup+0x23>
  80051b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80051e:	39 08                	cmp    %ecx,(%eax)
  800520:	75 0c                	jne    80052e <dev_lookup+0x23>
			*dev = devtab[i];
  800522:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800525:	89 01                	mov    %eax,(%ecx)
			return 0;
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	eb 2e                	jmp    80055c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80052e:	8b 02                	mov    (%edx),%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	75 e7                	jne    80051b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800534:	a1 08 40 80 00       	mov    0x804008,%eax
  800539:	8b 40 48             	mov    0x48(%eax),%eax
  80053c:	83 ec 04             	sub    $0x4,%esp
  80053f:	51                   	push   %ecx
  800540:	50                   	push   %eax
  800541:	68 64 23 80 00       	push   $0x802364
  800546:	e8 47 11 00 00       	call   801692 <cprintf>
	*dev = 0;
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 10             	sub    $0x10,%esp
  800566:	8b 75 08             	mov    0x8(%ebp),%esi
  800569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80056c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80056f:	50                   	push   %eax
  800570:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800576:	c1 e8 0c             	shr    $0xc,%eax
  800579:	50                   	push   %eax
  80057a:	e8 36 ff ff ff       	call   8004b5 <fd_lookup>
  80057f:	83 c4 08             	add    $0x8,%esp
  800582:	85 c0                	test   %eax,%eax
  800584:	78 05                	js     80058b <fd_close+0x2d>
	    || fd != fd2)
  800586:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800589:	74 0c                	je     800597 <fd_close+0x39>
		return (must_exist ? r : 0);
  80058b:	84 db                	test   %bl,%bl
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	0f 44 c2             	cmove  %edx,%eax
  800595:	eb 41                	jmp    8005d8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80059d:	50                   	push   %eax
  80059e:	ff 36                	pushl  (%esi)
  8005a0:	e8 66 ff ff ff       	call   80050b <dev_lookup>
  8005a5:	89 c3                	mov    %eax,%ebx
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	78 1a                	js     8005c8 <fd_close+0x6a>
		if (dev->dev_close)
  8005ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8005b4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	74 0b                	je     8005c8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005bd:	83 ec 0c             	sub    $0xc,%esp
  8005c0:	56                   	push   %esi
  8005c1:	ff d0                	call   *%eax
  8005c3:	89 c3                	mov    %eax,%ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	6a 00                	push   $0x0
  8005ce:	e8 1c fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	89 d8                	mov    %ebx,%eax
}
  8005d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005db:	5b                   	pop    %ebx
  8005dc:	5e                   	pop    %esi
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 08             	pushl  0x8(%ebp)
  8005ec:	e8 c4 fe ff ff       	call   8004b5 <fd_lookup>
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	78 10                	js     800608 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	6a 01                	push   $0x1
  8005fd:	ff 75 f4             	pushl  -0xc(%ebp)
  800600:	e8 59 ff ff ff       	call   80055e <fd_close>
  800605:	83 c4 10             	add    $0x10,%esp
}
  800608:	c9                   	leave  
  800609:	c3                   	ret    

0080060a <close_all>:

void
close_all(void)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	53                   	push   %ebx
  80060e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800611:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	53                   	push   %ebx
  80061a:	e8 c0 ff ff ff       	call   8005df <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80061f:	83 c3 01             	add    $0x1,%ebx
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	83 fb 20             	cmp    $0x20,%ebx
  800628:	75 ec                	jne    800616 <close_all+0xc>
		close(i);
}
  80062a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	57                   	push   %edi
  800633:	56                   	push   %esi
  800634:	53                   	push   %ebx
  800635:	83 ec 2c             	sub    $0x2c,%esp
  800638:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80063b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80063e:	50                   	push   %eax
  80063f:	ff 75 08             	pushl  0x8(%ebp)
  800642:	e8 6e fe ff ff       	call   8004b5 <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	85 c0                	test   %eax,%eax
  80064c:	0f 88 c1 00 00 00    	js     800713 <dup+0xe4>
		return r;
	close(newfdnum);
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	56                   	push   %esi
  800656:	e8 84 ff ff ff       	call   8005df <close>

	newfd = INDEX2FD(newfdnum);
  80065b:	89 f3                	mov    %esi,%ebx
  80065d:	c1 e3 0c             	shl    $0xc,%ebx
  800660:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800666:	83 c4 04             	add    $0x4,%esp
  800669:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066c:	e8 de fd ff ff       	call   80044f <fd2data>
  800671:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800673:	89 1c 24             	mov    %ebx,(%esp)
  800676:	e8 d4 fd ff ff       	call   80044f <fd2data>
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800681:	89 f8                	mov    %edi,%eax
  800683:	c1 e8 16             	shr    $0x16,%eax
  800686:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80068d:	a8 01                	test   $0x1,%al
  80068f:	74 37                	je     8006c8 <dup+0x99>
  800691:	89 f8                	mov    %edi,%eax
  800693:	c1 e8 0c             	shr    $0xc,%eax
  800696:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80069d:	f6 c2 01             	test   $0x1,%dl
  8006a0:	74 26                	je     8006c8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8006b1:	50                   	push   %eax
  8006b2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b5:	6a 00                	push   $0x0
  8006b7:	57                   	push   %edi
  8006b8:	6a 00                	push   $0x0
  8006ba:	e8 ee fa ff ff       	call   8001ad <sys_page_map>
  8006bf:	89 c7                	mov    %eax,%edi
  8006c1:	83 c4 20             	add    $0x20,%esp
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	78 2e                	js     8006f6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cb:	89 d0                	mov    %edx,%eax
  8006cd:	c1 e8 0c             	shr    $0xc,%eax
  8006d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006d7:	83 ec 0c             	sub    $0xc,%esp
  8006da:	25 07 0e 00 00       	and    $0xe07,%eax
  8006df:	50                   	push   %eax
  8006e0:	53                   	push   %ebx
  8006e1:	6a 00                	push   $0x0
  8006e3:	52                   	push   %edx
  8006e4:	6a 00                	push   $0x0
  8006e6:	e8 c2 fa ff ff       	call   8001ad <sys_page_map>
  8006eb:	89 c7                	mov    %eax,%edi
  8006ed:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006f0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	79 1d                	jns    800713 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 00                	push   $0x0
  8006fc:	e8 ee fa ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800701:	83 c4 08             	add    $0x8,%esp
  800704:	ff 75 d4             	pushl  -0x2c(%ebp)
  800707:	6a 00                	push   $0x0
  800709:	e8 e1 fa ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	89 f8                	mov    %edi,%eax
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800725:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	53                   	push   %ebx
  80072a:	e8 86 fd ff ff       	call   8004b5 <fd_lookup>
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	89 c2                	mov    %eax,%edx
  800734:	85 c0                	test   %eax,%eax
  800736:	78 6d                	js     8007a5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	ff 30                	pushl  (%eax)
  800744:	e8 c2 fd ff ff       	call   80050b <dev_lookup>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 4c                	js     80079c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800750:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800753:	8b 42 08             	mov    0x8(%edx),%eax
  800756:	83 e0 03             	and    $0x3,%eax
  800759:	83 f8 01             	cmp    $0x1,%eax
  80075c:	75 21                	jne    80077f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 08 40 80 00       	mov    0x804008,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 a5 23 80 00       	push   $0x8023a5
  800770:	e8 1d 0f 00 00       	call   801692 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80077d:	eb 26                	jmp    8007a5 <read+0x8a>
	}
	if (!dev->dev_read)
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	8b 40 08             	mov    0x8(%eax),%eax
  800785:	85 c0                	test   %eax,%eax
  800787:	74 17                	je     8007a0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	52                   	push   %edx
  800793:	ff d0                	call   *%eax
  800795:	89 c2                	mov    %eax,%edx
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 09                	jmp    8007a5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	eb 05                	jmp    8007a5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	57                   	push   %edi
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c0:	eb 21                	jmp    8007e3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007c2:	83 ec 04             	sub    $0x4,%esp
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	29 d8                	sub    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	03 45 0c             	add    0xc(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	57                   	push   %edi
  8007d1:	e8 45 ff ff ff       	call   80071b <read>
		if (m < 0)
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	78 10                	js     8007ed <readn+0x41>
			return m;
		if (m == 0)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	74 0a                	je     8007eb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e1:	01 c3                	add    %eax,%ebx
  8007e3:	39 f3                	cmp    %esi,%ebx
  8007e5:	72 db                	jb     8007c2 <readn+0x16>
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	eb 02                	jmp    8007ed <readn+0x41>
  8007eb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	83 ec 14             	sub    $0x14,%esp
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800802:	50                   	push   %eax
  800803:	53                   	push   %ebx
  800804:	e8 ac fc ff ff       	call   8004b5 <fd_lookup>
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	89 c2                	mov    %eax,%edx
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 68                	js     80087a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	ff 30                	pushl  (%eax)
  80081e:	e8 e8 fc ff ff       	call   80050b <dev_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 47                	js     800871 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800831:	75 21                	jne    800854 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800833:	a1 08 40 80 00       	mov    0x804008,%eax
  800838:	8b 40 48             	mov    0x48(%eax),%eax
  80083b:	83 ec 04             	sub    $0x4,%esp
  80083e:	53                   	push   %ebx
  80083f:	50                   	push   %eax
  800840:	68 c1 23 80 00       	push   $0x8023c1
  800845:	e8 48 0e 00 00       	call   801692 <cprintf>
		return -E_INVAL;
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800852:	eb 26                	jmp    80087a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800857:	8b 52 0c             	mov    0xc(%edx),%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 17                	je     800875 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80085e:	83 ec 04             	sub    $0x4,%esp
  800861:	ff 75 10             	pushl  0x10(%ebp)
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	50                   	push   %eax
  800868:	ff d2                	call   *%edx
  80086a:	89 c2                	mov    %eax,%edx
  80086c:	83 c4 10             	add    $0x10,%esp
  80086f:	eb 09                	jmp    80087a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800871:	89 c2                	mov    %eax,%edx
  800873:	eb 05                	jmp    80087a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800875:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80087a:	89 d0                	mov    %edx,%eax
  80087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <seek>:

int
seek(int fdnum, off_t offset)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800887:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80088a:	50                   	push   %eax
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 22 fc ff ff       	call   8004b5 <fd_lookup>
  800893:	83 c4 08             	add    $0x8,%esp
  800896:	85 c0                	test   %eax,%eax
  800898:	78 0e                	js     8008a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80089a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	83 ec 14             	sub    $0x14,%esp
  8008b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	53                   	push   %ebx
  8008b9:	e8 f7 fb ff ff       	call   8004b5 <fd_lookup>
  8008be:	83 c4 08             	add    $0x8,%esp
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	78 65                	js     80092c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008cd:	50                   	push   %eax
  8008ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d1:	ff 30                	pushl  (%eax)
  8008d3:	e8 33 fc ff ff       	call   80050b <dev_lookup>
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	78 44                	js     800923 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e6:	75 21                	jne    800909 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008ed:	8b 40 48             	mov    0x48(%eax),%eax
  8008f0:	83 ec 04             	sub    $0x4,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	50                   	push   %eax
  8008f5:	68 84 23 80 00       	push   $0x802384
  8008fa:	e8 93 0d 00 00       	call   801692 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800907:	eb 23                	jmp    80092c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800909:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80090c:	8b 52 18             	mov    0x18(%edx),%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 14                	je     800927 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	50                   	push   %eax
  80091a:	ff d2                	call   *%edx
  80091c:	89 c2                	mov    %eax,%edx
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	eb 09                	jmp    80092c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800923:	89 c2                	mov    %eax,%edx
  800925:	eb 05                	jmp    80092c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800927:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	83 ec 14             	sub    $0x14,%esp
  80093a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800940:	50                   	push   %eax
  800941:	ff 75 08             	pushl  0x8(%ebp)
  800944:	e8 6c fb ff ff       	call   8004b5 <fd_lookup>
  800949:	83 c4 08             	add    $0x8,%esp
  80094c:	89 c2                	mov    %eax,%edx
  80094e:	85 c0                	test   %eax,%eax
  800950:	78 58                	js     8009aa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800958:	50                   	push   %eax
  800959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095c:	ff 30                	pushl  (%eax)
  80095e:	e8 a8 fb ff ff       	call   80050b <dev_lookup>
  800963:	83 c4 10             	add    $0x10,%esp
  800966:	85 c0                	test   %eax,%eax
  800968:	78 37                	js     8009a1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800971:	74 32                	je     8009a5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800973:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800976:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80097d:	00 00 00 
	stat->st_isdir = 0;
  800980:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800987:	00 00 00 
	stat->st_dev = dev;
  80098a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800990:	83 ec 08             	sub    $0x8,%esp
  800993:	53                   	push   %ebx
  800994:	ff 75 f0             	pushl  -0x10(%ebp)
  800997:	ff 50 14             	call   *0x14(%eax)
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	83 c4 10             	add    $0x10,%esp
  80099f:	eb 09                	jmp    8009aa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	eb 05                	jmp    8009aa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009aa:	89 d0                	mov    %edx,%eax
  8009ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	6a 00                	push   $0x0
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 0c 02 00 00       	call   800bcf <open>
  8009c3:	89 c3                	mov    %eax,%ebx
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	85 c0                	test   %eax,%eax
  8009ca:	78 1b                	js     8009e7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009cc:	83 ec 08             	sub    $0x8,%esp
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	50                   	push   %eax
  8009d3:	e8 5b ff ff ff       	call   800933 <fstat>
  8009d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8009da:	89 1c 24             	mov    %ebx,(%esp)
  8009dd:	e8 fd fb ff ff       	call   8005df <close>
	return r;
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	89 f0                	mov    %esi,%eax
}
  8009e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	89 c6                	mov    %eax,%esi
  8009f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009f7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009fe:	75 12                	jne    800a12 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a00:	83 ec 0c             	sub    $0xc,%esp
  800a03:	6a 01                	push   $0x1
  800a05:	e8 11 16 00 00       	call   80201b <ipc_find_env>
  800a0a:	a3 00 40 80 00       	mov    %eax,0x804000
  800a0f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a12:	6a 07                	push   $0x7
  800a14:	68 00 50 80 00       	push   $0x805000
  800a19:	56                   	push   %esi
  800a1a:	ff 35 00 40 80 00    	pushl  0x804000
  800a20:	e8 a2 15 00 00       	call   801fc7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a25:	83 c4 0c             	add    $0xc,%esp
  800a28:	6a 00                	push   $0x0
  800a2a:	53                   	push   %ebx
  800a2b:	6a 00                	push   $0x0
  800a2d:	e8 2c 15 00 00       	call   801f5e <ipc_recv>
}
  800a32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 40 0c             	mov    0xc(%eax),%eax
  800a45:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 02 00 00 00       	mov    $0x2,%eax
  800a5c:	e8 8d ff ff ff       	call   8009ee <fsipc>
}
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
  800a79:	b8 06 00 00 00       	mov    $0x6,%eax
  800a7e:	e8 6b ff ff ff       	call   8009ee <fsipc>
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	83 ec 04             	sub    $0x4,%esp
  800a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 40 0c             	mov    0xc(%eax),%eax
  800a95:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 05 00 00 00       	mov    $0x5,%eax
  800aa4:	e8 45 ff ff ff       	call   8009ee <fsipc>
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 2c                	js     800ad9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aad:	83 ec 08             	sub    $0x8,%esp
  800ab0:	68 00 50 80 00       	push   $0x805000
  800ab5:	53                   	push   %ebx
  800ab6:	e8 5c 11 00 00       	call   801c17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800abb:	a1 80 50 80 00       	mov    0x805080,%eax
  800ac0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ac6:	a1 84 50 80 00       	mov    0x805084,%eax
  800acb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 52 0c             	mov    0xc(%edx),%edx
  800aee:	89 15 00 50 80 00    	mov    %edx,0x805000
  800af4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800af9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800afe:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800b01:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800b07:	53                   	push   %ebx
  800b08:	ff 75 0c             	pushl  0xc(%ebp)
  800b0b:	68 08 50 80 00       	push   $0x805008
  800b10:	e8 94 12 00 00       	call   801da9 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1f:	e8 ca fe ff ff       	call   8009ee <fsipc>
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	85 c0                	test   %eax,%eax
  800b29:	78 1d                	js     800b48 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800b2b:	39 d8                	cmp    %ebx,%eax
  800b2d:	76 19                	jbe    800b48 <devfile_write+0x6a>
  800b2f:	68 f4 23 80 00       	push   $0x8023f4
  800b34:	68 00 24 80 00       	push   $0x802400
  800b39:	68 a5 00 00 00       	push   $0xa5
  800b3e:	68 15 24 80 00       	push   $0x802415
  800b43:	e8 71 0a 00 00       	call   8015b9 <_panic>
	return r;
}
  800b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 40 0c             	mov    0xc(%eax),%eax
  800b5b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b60:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	e8 79 fe ff ff       	call   8009ee <fsipc>
  800b75:	89 c3                	mov    %eax,%ebx
  800b77:	85 c0                	test   %eax,%eax
  800b79:	78 4b                	js     800bc6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b7b:	39 c6                	cmp    %eax,%esi
  800b7d:	73 16                	jae    800b95 <devfile_read+0x48>
  800b7f:	68 20 24 80 00       	push   $0x802420
  800b84:	68 00 24 80 00       	push   $0x802400
  800b89:	6a 7c                	push   $0x7c
  800b8b:	68 15 24 80 00       	push   $0x802415
  800b90:	e8 24 0a 00 00       	call   8015b9 <_panic>
	assert(r <= PGSIZE);
  800b95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b9a:	7e 16                	jle    800bb2 <devfile_read+0x65>
  800b9c:	68 27 24 80 00       	push   $0x802427
  800ba1:	68 00 24 80 00       	push   $0x802400
  800ba6:	6a 7d                	push   $0x7d
  800ba8:	68 15 24 80 00       	push   $0x802415
  800bad:	e8 07 0a 00 00       	call   8015b9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bb2:	83 ec 04             	sub    $0x4,%esp
  800bb5:	50                   	push   %eax
  800bb6:	68 00 50 80 00       	push   $0x805000
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	e8 e6 11 00 00       	call   801da9 <memmove>
	return r;
  800bc3:	83 c4 10             	add    $0x10,%esp
}
  800bc6:	89 d8                	mov    %ebx,%eax
  800bc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 20             	sub    $0x20,%esp
  800bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bd9:	53                   	push   %ebx
  800bda:	e8 ff 0f 00 00       	call   801bde <strlen>
  800bdf:	83 c4 10             	add    $0x10,%esp
  800be2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800be7:	7f 67                	jg     800c50 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bef:	50                   	push   %eax
  800bf0:	e8 71 f8 ff ff       	call   800466 <fd_alloc>
  800bf5:	83 c4 10             	add    $0x10,%esp
		return r;
  800bf8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	78 57                	js     800c55 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	53                   	push   %ebx
  800c02:	68 00 50 80 00       	push   $0x805000
  800c07:	e8 0b 10 00 00       	call   801c17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c17:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1c:	e8 cd fd ff ff       	call   8009ee <fsipc>
  800c21:	89 c3                	mov    %eax,%ebx
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	79 14                	jns    800c3e <open+0x6f>
		fd_close(fd, 0);
  800c2a:	83 ec 08             	sub    $0x8,%esp
  800c2d:	6a 00                	push   $0x0
  800c2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800c32:	e8 27 f9 ff ff       	call   80055e <fd_close>
		return r;
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	89 da                	mov    %ebx,%edx
  800c3c:	eb 17                	jmp    800c55 <open+0x86>
	}

	return fd2num(fd);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	ff 75 f4             	pushl  -0xc(%ebp)
  800c44:	e8 f6 f7 ff ff       	call   80043f <fd2num>
  800c49:	89 c2                	mov    %eax,%edx
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	eb 05                	jmp    800c55 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c50:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c55:	89 d0                	mov    %edx,%eax
  800c57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
  800c67:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6c:	e8 7d fd ff ff       	call   8009ee <fsipc>
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c79:	68 33 24 80 00       	push   $0x802433
  800c7e:	ff 75 0c             	pushl  0xc(%ebp)
  800c81:	e8 91 0f 00 00       	call   801c17 <strcpy>
	return 0;
}
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	53                   	push   %ebx
  800c91:	83 ec 10             	sub    $0x10,%esp
  800c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c97:	53                   	push   %ebx
  800c98:	e8 b7 13 00 00       	call   802054 <pageref>
  800c9d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800ca5:	83 f8 01             	cmp    $0x1,%eax
  800ca8:	75 10                	jne    800cba <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	ff 73 0c             	pushl  0xc(%ebx)
  800cb0:	e8 c0 02 00 00       	call   800f75 <nsipc_close>
  800cb5:	89 c2                	mov    %eax,%edx
  800cb7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800cba:	89 d0                	mov    %edx,%eax
  800cbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800cc7:	6a 00                	push   $0x0
  800cc9:	ff 75 10             	pushl  0x10(%ebp)
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	ff 70 0c             	pushl  0xc(%eax)
  800cd5:	e8 78 03 00 00       	call   801052 <nsipc_send>
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    

00800cdc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800ce2:	6a 00                	push   $0x0
  800ce4:	ff 75 10             	pushl  0x10(%ebp)
  800ce7:	ff 75 0c             	pushl  0xc(%ebp)
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	ff 70 0c             	pushl  0xc(%eax)
  800cf0:	e8 f1 02 00 00       	call   800fe6 <nsipc_recv>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cfd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800d00:	52                   	push   %edx
  800d01:	50                   	push   %eax
  800d02:	e8 ae f7 ff ff       	call   8004b5 <fd_lookup>
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 17                	js     800d25 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d11:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800d17:	39 08                	cmp    %ecx,(%eax)
  800d19:	75 05                	jne    800d20 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800d1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d1e:	eb 05                	jmp    800d25 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800d20:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
  800d2f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d34:	50                   	push   %eax
  800d35:	e8 2c f7 ff ff       	call   800466 <fd_alloc>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	78 1b                	js     800d5e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	68 07 04 00 00       	push   $0x407
  800d4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d4e:	6a 00                	push   $0x0
  800d50:	e8 15 f4 ff ff       	call   80016a <sys_page_alloc>
  800d55:	89 c3                	mov    %eax,%ebx
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	79 10                	jns    800d6e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	56                   	push   %esi
  800d62:	e8 0e 02 00 00       	call   800f75 <nsipc_close>
		return r;
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	89 d8                	mov    %ebx,%eax
  800d6c:	eb 24                	jmp    800d92 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d6e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d77:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d83:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	e8 b0 f6 ff ff       	call   80043f <fd2num>
  800d8f:	83 c4 10             	add    $0x10,%esp
}
  800d92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	e8 50 ff ff ff       	call   800cf7 <fd2sockid>
		return r;
  800da7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 1f                	js     800dcc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	ff 75 10             	pushl  0x10(%ebp)
  800db3:	ff 75 0c             	pushl  0xc(%ebp)
  800db6:	50                   	push   %eax
  800db7:	e8 12 01 00 00       	call   800ece <nsipc_accept>
  800dbc:	83 c4 10             	add    $0x10,%esp
		return r;
  800dbf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 07                	js     800dcc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800dc5:	e8 5d ff ff ff       	call   800d27 <alloc_sockfd>
  800dca:	89 c1                	mov    %eax,%ecx
}
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	e8 19 ff ff ff       	call   800cf7 <fd2sockid>
  800dde:	85 c0                	test   %eax,%eax
  800de0:	78 12                	js     800df4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	ff 75 0c             	pushl  0xc(%ebp)
  800deb:	50                   	push   %eax
  800dec:	e8 2d 01 00 00       	call   800f1e <nsipc_bind>
  800df1:	83 c4 10             	add    $0x10,%esp
}
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    

00800df6 <shutdown>:

int
shutdown(int s, int how)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	e8 f3 fe ff ff       	call   800cf7 <fd2sockid>
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 0f                	js     800e17 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	ff 75 0c             	pushl  0xc(%ebp)
  800e0e:	50                   	push   %eax
  800e0f:	e8 3f 01 00 00       	call   800f53 <nsipc_shutdown>
  800e14:	83 c4 10             	add    $0x10,%esp
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	e8 d0 fe ff ff       	call   800cf7 <fd2sockid>
  800e27:	85 c0                	test   %eax,%eax
  800e29:	78 12                	js     800e3d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	ff 75 10             	pushl  0x10(%ebp)
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	50                   	push   %eax
  800e35:	e8 55 01 00 00       	call   800f8f <nsipc_connect>
  800e3a:	83 c4 10             	add    $0x10,%esp
}
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <listen>:

int
listen(int s, int backlog)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	e8 aa fe ff ff       	call   800cf7 <fd2sockid>
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	78 0f                	js     800e60 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	ff 75 0c             	pushl  0xc(%ebp)
  800e57:	50                   	push   %eax
  800e58:	e8 67 01 00 00       	call   800fc4 <nsipc_listen>
  800e5d:	83 c4 10             	add    $0x10,%esp
}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e68:	ff 75 10             	pushl  0x10(%ebp)
  800e6b:	ff 75 0c             	pushl  0xc(%ebp)
  800e6e:	ff 75 08             	pushl  0x8(%ebp)
  800e71:	e8 3a 02 00 00       	call   8010b0 <nsipc_socket>
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	78 05                	js     800e82 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e7d:	e8 a5 fe ff ff       	call   800d27 <alloc_sockfd>
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e8d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e94:	75 12                	jne    800ea8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	6a 02                	push   $0x2
  800e9b:	e8 7b 11 00 00       	call   80201b <ipc_find_env>
  800ea0:	a3 04 40 80 00       	mov    %eax,0x804004
  800ea5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ea8:	6a 07                	push   $0x7
  800eaa:	68 00 60 80 00       	push   $0x806000
  800eaf:	53                   	push   %ebx
  800eb0:	ff 35 04 40 80 00    	pushl  0x804004
  800eb6:	e8 0c 11 00 00       	call   801fc7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800ebb:	83 c4 0c             	add    $0xc,%esp
  800ebe:	6a 00                	push   $0x0
  800ec0:	6a 00                	push   $0x0
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 95 10 00 00       	call   801f5e <ipc_recv>
}
  800ec9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecc:	c9                   	leave  
  800ecd:	c3                   	ret    

00800ece <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ede:	8b 06                	mov    (%esi),%eax
  800ee0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ee5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eea:	e8 95 ff ff ff       	call   800e84 <nsipc>
  800eef:	89 c3                	mov    %eax,%ebx
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 20                	js     800f15 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	ff 35 10 60 80 00    	pushl  0x806010
  800efe:	68 00 60 80 00       	push   $0x806000
  800f03:	ff 75 0c             	pushl  0xc(%ebp)
  800f06:	e8 9e 0e 00 00       	call   801da9 <memmove>
		*addrlen = ret->ret_addrlen;
  800f0b:	a1 10 60 80 00       	mov    0x806010,%eax
  800f10:	89 06                	mov    %eax,(%esi)
  800f12:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800f15:	89 d8                	mov    %ebx,%eax
  800f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f30:	53                   	push   %ebx
  800f31:	ff 75 0c             	pushl  0xc(%ebp)
  800f34:	68 04 60 80 00       	push   $0x806004
  800f39:	e8 6b 0e 00 00       	call   801da9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f3e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f44:	b8 02 00 00 00       	mov    $0x2,%eax
  800f49:	e8 36 ff ff ff       	call   800e84 <nsipc>
}
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f69:	b8 03 00 00 00       	mov    $0x3,%eax
  800f6e:	e8 11 ff ff ff       	call   800e84 <nsipc>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <nsipc_close>:

int
nsipc_close(int s)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f83:	b8 04 00 00 00       	mov    $0x4,%eax
  800f88:	e8 f7 fe ff ff       	call   800e84 <nsipc>
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	53                   	push   %ebx
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800fa1:	53                   	push   %ebx
  800fa2:	ff 75 0c             	pushl  0xc(%ebp)
  800fa5:	68 04 60 80 00       	push   $0x806004
  800faa:	e8 fa 0d 00 00       	call   801da9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800faf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800fb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800fba:	e8 c5 fe ff ff       	call   800e84 <nsipc>
}
  800fbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800fca:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fda:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdf:	e8 a0 fe ff ff       	call   800e84 <nsipc>
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800ff6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fff:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801004:	b8 07 00 00 00       	mov    $0x7,%eax
  801009:	e8 76 fe ff ff       	call   800e84 <nsipc>
  80100e:	89 c3                	mov    %eax,%ebx
  801010:	85 c0                	test   %eax,%eax
  801012:	78 35                	js     801049 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801014:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801019:	7f 04                	jg     80101f <nsipc_recv+0x39>
  80101b:	39 c6                	cmp    %eax,%esi
  80101d:	7d 16                	jge    801035 <nsipc_recv+0x4f>
  80101f:	68 3f 24 80 00       	push   $0x80243f
  801024:	68 00 24 80 00       	push   $0x802400
  801029:	6a 62                	push   $0x62
  80102b:	68 54 24 80 00       	push   $0x802454
  801030:	e8 84 05 00 00       	call   8015b9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	50                   	push   %eax
  801039:	68 00 60 80 00       	push   $0x806000
  80103e:	ff 75 0c             	pushl  0xc(%ebp)
  801041:	e8 63 0d 00 00       	call   801da9 <memmove>
  801046:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	53                   	push   %ebx
  801056:	83 ec 04             	sub    $0x4,%esp
  801059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801064:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80106a:	7e 16                	jle    801082 <nsipc_send+0x30>
  80106c:	68 60 24 80 00       	push   $0x802460
  801071:	68 00 24 80 00       	push   $0x802400
  801076:	6a 6d                	push   $0x6d
  801078:	68 54 24 80 00       	push   $0x802454
  80107d:	e8 37 05 00 00       	call   8015b9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	53                   	push   %ebx
  801086:	ff 75 0c             	pushl  0xc(%ebp)
  801089:	68 0c 60 80 00       	push   $0x80600c
  80108e:	e8 16 0d 00 00       	call   801da9 <memmove>
	nsipcbuf.send.req_size = size;
  801093:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801099:	8b 45 14             	mov    0x14(%ebp),%eax
  80109c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8010a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8010a6:	e8 d9 fd ff ff       	call   800e84 <nsipc>
}
  8010ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8010d3:	e8 ac fd ff ff       	call   800e84 <nsipc>
}
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	ff 75 08             	pushl  0x8(%ebp)
  8010e8:	e8 62 f3 ff ff       	call   80044f <fd2data>
  8010ed:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	68 6c 24 80 00       	push   $0x80246c
  8010f7:	53                   	push   %ebx
  8010f8:	e8 1a 0b 00 00       	call   801c17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010fd:	8b 46 04             	mov    0x4(%esi),%eax
  801100:	2b 06                	sub    (%esi),%eax
  801102:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801108:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80110f:	00 00 00 
	stat->st_dev = &devpipe;
  801112:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801119:	30 80 00 
	return 0;
}
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
  801121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801132:	53                   	push   %ebx
  801133:	6a 00                	push   $0x0
  801135:	e8 b5 f0 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80113a:	89 1c 24             	mov    %ebx,(%esp)
  80113d:	e8 0d f3 ff ff       	call   80044f <fd2data>
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	50                   	push   %eax
  801146:	6a 00                	push   $0x0
  801148:	e8 a2 f0 ff ff       	call   8001ef <sys_page_unmap>
}
  80114d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 1c             	sub    $0x1c,%esp
  80115b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801160:	a1 08 40 80 00       	mov    0x804008,%eax
  801165:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	ff 75 e0             	pushl  -0x20(%ebp)
  80116e:	e8 e1 0e 00 00       	call   802054 <pageref>
  801173:	89 c3                	mov    %eax,%ebx
  801175:	89 3c 24             	mov    %edi,(%esp)
  801178:	e8 d7 0e 00 00       	call   802054 <pageref>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	39 c3                	cmp    %eax,%ebx
  801182:	0f 94 c1             	sete   %cl
  801185:	0f b6 c9             	movzbl %cl,%ecx
  801188:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80118b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801191:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801194:	39 ce                	cmp    %ecx,%esi
  801196:	74 1b                	je     8011b3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801198:	39 c3                	cmp    %eax,%ebx
  80119a:	75 c4                	jne    801160 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80119c:	8b 42 58             	mov    0x58(%edx),%eax
  80119f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a2:	50                   	push   %eax
  8011a3:	56                   	push   %esi
  8011a4:	68 73 24 80 00       	push   $0x802473
  8011a9:	e8 e4 04 00 00       	call   801692 <cprintf>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	eb ad                	jmp    801160 <_pipeisclosed+0xe>
	}
}
  8011b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 28             	sub    $0x28,%esp
  8011c7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011ca:	56                   	push   %esi
  8011cb:	e8 7f f2 ff ff       	call   80044f <fd2data>
  8011d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	bf 00 00 00 00       	mov    $0x0,%edi
  8011da:	eb 4b                	jmp    801227 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011dc:	89 da                	mov    %ebx,%edx
  8011de:	89 f0                	mov    %esi,%eax
  8011e0:	e8 6d ff ff ff       	call   801152 <_pipeisclosed>
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	75 48                	jne    801231 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011e9:	e8 5d ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011ee:	8b 43 04             	mov    0x4(%ebx),%eax
  8011f1:	8b 0b                	mov    (%ebx),%ecx
  8011f3:	8d 51 20             	lea    0x20(%ecx),%edx
  8011f6:	39 d0                	cmp    %edx,%eax
  8011f8:	73 e2                	jae    8011dc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801201:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 fa 1f             	sar    $0x1f,%edx
  801209:	89 d1                	mov    %edx,%ecx
  80120b:	c1 e9 1b             	shr    $0x1b,%ecx
  80120e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801211:	83 e2 1f             	and    $0x1f,%edx
  801214:	29 ca                	sub    %ecx,%edx
  801216:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80121a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80121e:	83 c0 01             	add    $0x1,%eax
  801221:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801224:	83 c7 01             	add    $0x1,%edi
  801227:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80122a:	75 c2                	jne    8011ee <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80122c:	8b 45 10             	mov    0x10(%ebp),%eax
  80122f:	eb 05                	jmp    801236 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 18             	sub    $0x18,%esp
  801247:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80124a:	57                   	push   %edi
  80124b:	e8 ff f1 ff ff       	call   80044f <fd2data>
  801250:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125a:	eb 3d                	jmp    801299 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80125c:	85 db                	test   %ebx,%ebx
  80125e:	74 04                	je     801264 <devpipe_read+0x26>
				return i;
  801260:	89 d8                	mov    %ebx,%eax
  801262:	eb 44                	jmp    8012a8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801264:	89 f2                	mov    %esi,%edx
  801266:	89 f8                	mov    %edi,%eax
  801268:	e8 e5 fe ff ff       	call   801152 <_pipeisclosed>
  80126d:	85 c0                	test   %eax,%eax
  80126f:	75 32                	jne    8012a3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801271:	e8 d5 ee ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801276:	8b 06                	mov    (%esi),%eax
  801278:	3b 46 04             	cmp    0x4(%esi),%eax
  80127b:	74 df                	je     80125c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80127d:	99                   	cltd   
  80127e:	c1 ea 1b             	shr    $0x1b,%edx
  801281:	01 d0                	add    %edx,%eax
  801283:	83 e0 1f             	and    $0x1f,%eax
  801286:	29 d0                	sub    %edx,%eax
  801288:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80128d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801290:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801293:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801296:	83 c3 01             	add    $0x1,%ebx
  801299:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80129c:	75 d8                	jne    801276 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80129e:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a1:	eb 05                	jmp    8012a8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5f                   	pop    %edi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	e8 a5 f1 ff ff       	call   800466 <fd_alloc>
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	0f 88 2c 01 00 00    	js     8013fa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	68 07 04 00 00       	push   $0x407
  8012d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 8a ee ff ff       	call   80016a <sys_page_alloc>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	0f 88 0d 01 00 00    	js     8013fa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	e8 6d f1 ff ff       	call   800466 <fd_alloc>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	0f 88 e2 00 00 00    	js     8013e8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	68 07 04 00 00       	push   $0x407
  80130e:	ff 75 f0             	pushl  -0x10(%ebp)
  801311:	6a 00                	push   $0x0
  801313:	e8 52 ee ff ff       	call   80016a <sys_page_alloc>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	0f 88 c3 00 00 00    	js     8013e8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	ff 75 f4             	pushl  -0xc(%ebp)
  80132b:	e8 1f f1 ff ff       	call   80044f <fd2data>
  801330:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801332:	83 c4 0c             	add    $0xc,%esp
  801335:	68 07 04 00 00       	push   $0x407
  80133a:	50                   	push   %eax
  80133b:	6a 00                	push   $0x0
  80133d:	e8 28 ee ff ff       	call   80016a <sys_page_alloc>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	0f 88 89 00 00 00    	js     8013d8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 f0             	pushl  -0x10(%ebp)
  801355:	e8 f5 f0 ff ff       	call   80044f <fd2data>
  80135a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801361:	50                   	push   %eax
  801362:	6a 00                	push   $0x0
  801364:	56                   	push   %esi
  801365:	6a 00                	push   $0x0
  801367:	e8 41 ee ff ff       	call   8001ad <sys_page_map>
  80136c:	89 c3                	mov    %eax,%ebx
  80136e:	83 c4 20             	add    $0x20,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 55                	js     8013ca <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801375:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801383:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80138a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801398:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a5:	e8 95 f0 ff ff       	call   80043f <fd2num>
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013af:	83 c4 04             	add    $0x4,%esp
  8013b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b5:	e8 85 f0 ff ff       	call   80043f <fd2num>
  8013ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c8:	eb 30                	jmp    8013fa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	56                   	push   %esi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 1a ee ff ff       	call   8001ef <sys_page_unmap>
  8013d5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	ff 75 f0             	pushl  -0x10(%ebp)
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 0a ee ff ff       	call   8001ef <sys_page_unmap>
  8013e5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 fa ed ff ff       	call   8001ef <sys_page_unmap>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013fa:	89 d0                	mov    %edx,%eax
  8013fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801409:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 08             	pushl  0x8(%ebp)
  801410:	e8 a0 f0 ff ff       	call   8004b5 <fd_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 18                	js     801434 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	ff 75 f4             	pushl  -0xc(%ebp)
  801422:	e8 28 f0 ff ff       	call   80044f <fd2data>
	return _pipeisclosed(fd, p);
  801427:	89 c2                	mov    %eax,%edx
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	e8 21 fd ff ff       	call   801152 <_pipeisclosed>
  801431:	83 c4 10             	add    $0x10,%esp
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801446:	68 8b 24 80 00       	push   $0x80248b
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	e8 c4 07 00 00       	call   801c17 <strcpy>
	return 0;
}
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	57                   	push   %edi
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801466:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80146b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801471:	eb 2d                	jmp    8014a0 <devcons_write+0x46>
		m = n - tot;
  801473:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801476:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801478:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80147b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801480:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	53                   	push   %ebx
  801487:	03 45 0c             	add    0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	57                   	push   %edi
  80148c:	e8 18 09 00 00       	call   801da9 <memmove>
		sys_cputs(buf, m);
  801491:	83 c4 08             	add    $0x8,%esp
  801494:	53                   	push   %ebx
  801495:	57                   	push   %edi
  801496:	e8 13 ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80149b:	01 de                	add    %ebx,%esi
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	89 f0                	mov    %esi,%eax
  8014a2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014a5:	72 cc                	jb     801473 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014be:	74 2a                	je     8014ea <devcons_read+0x3b>
  8014c0:	eb 05                	jmp    8014c7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014c2:	e8 84 ec ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014c7:	e8 00 ec ff ff       	call   8000cc <sys_cgetc>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	74 f2                	je     8014c2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 16                	js     8014ea <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014d4:	83 f8 04             	cmp    $0x4,%eax
  8014d7:	74 0c                	je     8014e5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014dc:	88 02                	mov    %al,(%edx)
	return 1;
  8014de:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e3:	eb 05                	jmp    8014ea <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014f8:	6a 01                	push   $0x1
  8014fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	e8 ab eb ff ff       	call   8000ae <sys_cputs>
}
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <getchar>:

int
getchar(void)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80150e:	6a 01                	push   $0x1
  801510:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	6a 00                	push   $0x0
  801516:	e8 00 f2 ff ff       	call   80071b <read>
	if (r < 0)
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 0f                	js     801531 <getchar+0x29>
		return r;
	if (r < 1)
  801522:	85 c0                	test   %eax,%eax
  801524:	7e 06                	jle    80152c <getchar+0x24>
		return -E_EOF;
	return c;
  801526:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80152a:	eb 05                	jmp    801531 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80152c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	ff 75 08             	pushl  0x8(%ebp)
  801540:	e8 70 ef ff ff       	call   8004b5 <fd_lookup>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 11                	js     80155d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154f:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801555:	39 10                	cmp    %edx,(%eax)
  801557:	0f 94 c0             	sete   %al
  80155a:	0f b6 c0             	movzbl %al,%eax
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <opencons>:

int
opencons(void)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	e8 f8 ee ff ff       	call   800466 <fd_alloc>
  80156e:	83 c4 10             	add    $0x10,%esp
		return r;
  801571:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801573:	85 c0                	test   %eax,%eax
  801575:	78 3e                	js     8015b5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	68 07 04 00 00       	push   $0x407
  80157f:	ff 75 f4             	pushl  -0xc(%ebp)
  801582:	6a 00                	push   $0x0
  801584:	e8 e1 eb ff ff       	call   80016a <sys_page_alloc>
  801589:	83 c4 10             	add    $0x10,%esp
		return r;
  80158c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 23                	js     8015b5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801592:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80159d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	50                   	push   %eax
  8015ab:	e8 8f ee ff ff       	call   80043f <fd2num>
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	83 c4 10             	add    $0x10,%esp
}
  8015b5:	89 d0                	mov    %edx,%eax
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015be:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015c1:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8015c7:	e8 60 eb ff ff       	call   80012c <sys_getenvid>
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	56                   	push   %esi
  8015d6:	50                   	push   %eax
  8015d7:	68 98 24 80 00       	push   $0x802498
  8015dc:	e8 b1 00 00 00       	call   801692 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015e1:	83 c4 18             	add    $0x18,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	ff 75 10             	pushl  0x10(%ebp)
  8015e8:	e8 54 00 00 00       	call   801641 <vcprintf>
	cprintf("\n");
  8015ed:	c7 04 24 84 24 80 00 	movl   $0x802484,(%esp)
  8015f4:	e8 99 00 00 00       	call   801692 <cprintf>
  8015f9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015fc:	cc                   	int3   
  8015fd:	eb fd                	jmp    8015fc <_panic+0x43>

008015ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801609:	8b 13                	mov    (%ebx),%edx
  80160b:	8d 42 01             	lea    0x1(%edx),%eax
  80160e:	89 03                	mov    %eax,(%ebx)
  801610:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801613:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801617:	3d ff 00 00 00       	cmp    $0xff,%eax
  80161c:	75 1a                	jne    801638 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	68 ff 00 00 00       	push   $0xff
  801626:	8d 43 08             	lea    0x8(%ebx),%eax
  801629:	50                   	push   %eax
  80162a:	e8 7f ea ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80162f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801635:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801638:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80164a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801651:	00 00 00 
	b.cnt = 0;
  801654:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80165b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	ff 75 08             	pushl  0x8(%ebp)
  801664:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	68 ff 15 80 00       	push   $0x8015ff
  801670:	e8 54 01 00 00       	call   8017c9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801675:	83 c4 08             	add    $0x8,%esp
  801678:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80167e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	e8 24 ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80168a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801698:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 9d ff ff ff       	call   801641 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	57                   	push   %edi
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 1c             	sub    $0x1c,%esp
  8016af:	89 c7                	mov    %eax,%edi
  8016b1:	89 d6                	mov    %edx,%esi
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016ca:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016cd:	39 d3                	cmp    %edx,%ebx
  8016cf:	72 05                	jb     8016d6 <printnum+0x30>
  8016d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016d4:	77 45                	ja     80171b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016d6:	83 ec 0c             	sub    $0xc,%esp
  8016d9:	ff 75 18             	pushl  0x18(%ebp)
  8016dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8016df:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016e2:	53                   	push   %ebx
  8016e3:	ff 75 10             	pushl  0x10(%ebp)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8016f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016f5:	e8 96 09 00 00       	call   802090 <__udivdi3>
  8016fa:	83 c4 18             	add    $0x18,%esp
  8016fd:	52                   	push   %edx
  8016fe:	50                   	push   %eax
  8016ff:	89 f2                	mov    %esi,%edx
  801701:	89 f8                	mov    %edi,%eax
  801703:	e8 9e ff ff ff       	call   8016a6 <printnum>
  801708:	83 c4 20             	add    $0x20,%esp
  80170b:	eb 18                	jmp    801725 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	56                   	push   %esi
  801711:	ff 75 18             	pushl  0x18(%ebp)
  801714:	ff d7                	call   *%edi
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	eb 03                	jmp    80171e <printnum+0x78>
  80171b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80171e:	83 eb 01             	sub    $0x1,%ebx
  801721:	85 db                	test   %ebx,%ebx
  801723:	7f e8                	jg     80170d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	56                   	push   %esi
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80172f:	ff 75 e0             	pushl  -0x20(%ebp)
  801732:	ff 75 dc             	pushl  -0x24(%ebp)
  801735:	ff 75 d8             	pushl  -0x28(%ebp)
  801738:	e8 83 0a 00 00       	call   8021c0 <__umoddi3>
  80173d:	83 c4 14             	add    $0x14,%esp
  801740:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  801747:	50                   	push   %eax
  801748:	ff d7                	call   *%edi
}
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5f                   	pop    %edi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801758:	83 fa 01             	cmp    $0x1,%edx
  80175b:	7e 0e                	jle    80176b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80175d:	8b 10                	mov    (%eax),%edx
  80175f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801762:	89 08                	mov    %ecx,(%eax)
  801764:	8b 02                	mov    (%edx),%eax
  801766:	8b 52 04             	mov    0x4(%edx),%edx
  801769:	eb 22                	jmp    80178d <getuint+0x38>
	else if (lflag)
  80176b:	85 d2                	test   %edx,%edx
  80176d:	74 10                	je     80177f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80176f:	8b 10                	mov    (%eax),%edx
  801771:	8d 4a 04             	lea    0x4(%edx),%ecx
  801774:	89 08                	mov    %ecx,(%eax)
  801776:	8b 02                	mov    (%edx),%eax
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	eb 0e                	jmp    80178d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80177f:	8b 10                	mov    (%eax),%edx
  801781:	8d 4a 04             	lea    0x4(%edx),%ecx
  801784:	89 08                	mov    %ecx,(%eax)
  801786:	8b 02                	mov    (%edx),%eax
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801795:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801799:	8b 10                	mov    (%eax),%edx
  80179b:	3b 50 04             	cmp    0x4(%eax),%edx
  80179e:	73 0a                	jae    8017aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8017a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017a3:	89 08                	mov    %ecx,(%eax)
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	88 02                	mov    %al,(%edx)
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017b5:	50                   	push   %eax
  8017b6:	ff 75 10             	pushl  0x10(%ebp)
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	ff 75 08             	pushl  0x8(%ebp)
  8017bf:	e8 05 00 00 00       	call   8017c9 <vprintfmt>
	va_end(ap);
}
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	57                   	push   %edi
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 2c             	sub    $0x2c,%esp
  8017d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017d8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017db:	eb 12                	jmp    8017ef <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	0f 84 89 03 00 00    	je     801b6e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	53                   	push   %ebx
  8017e9:	50                   	push   %eax
  8017ea:	ff d6                	call   *%esi
  8017ec:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017ef:	83 c7 01             	add    $0x1,%edi
  8017f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017f6:	83 f8 25             	cmp    $0x25,%eax
  8017f9:	75 e2                	jne    8017dd <vprintfmt+0x14>
  8017fb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017ff:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801806:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80180d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	eb 07                	jmp    801822 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80181e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801822:	8d 47 01             	lea    0x1(%edi),%eax
  801825:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801828:	0f b6 07             	movzbl (%edi),%eax
  80182b:	0f b6 c8             	movzbl %al,%ecx
  80182e:	83 e8 23             	sub    $0x23,%eax
  801831:	3c 55                	cmp    $0x55,%al
  801833:	0f 87 1a 03 00 00    	ja     801b53 <vprintfmt+0x38a>
  801839:	0f b6 c0             	movzbl %al,%eax
  80183c:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  801843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801846:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80184a:	eb d6                	jmp    801822 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801857:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80185a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80185e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801861:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801864:	83 fa 09             	cmp    $0x9,%edx
  801867:	77 39                	ja     8018a2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801869:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80186c:	eb e9                	jmp    801857 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80186e:	8b 45 14             	mov    0x14(%ebp),%eax
  801871:	8d 48 04             	lea    0x4(%eax),%ecx
  801874:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801877:	8b 00                	mov    (%eax),%eax
  801879:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80187f:	eb 27                	jmp    8018a8 <vprintfmt+0xdf>
  801881:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801884:	85 c0                	test   %eax,%eax
  801886:	b9 00 00 00 00       	mov    $0x0,%ecx
  80188b:	0f 49 c8             	cmovns %eax,%ecx
  80188e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801894:	eb 8c                	jmp    801822 <vprintfmt+0x59>
  801896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801899:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018a0:	eb 80                	jmp    801822 <vprintfmt+0x59>
  8018a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018a5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ac:	0f 89 70 ff ff ff    	jns    801822 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018bf:	e9 5e ff ff ff       	jmp    801822 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018c4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018ca:	e9 53 ff ff ff       	jmp    801822 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d2:	8d 50 04             	lea    0x4(%eax),%edx
  8018d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	53                   	push   %ebx
  8018dc:	ff 30                	pushl  (%eax)
  8018de:	ff d6                	call   *%esi
			break;
  8018e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018e6:	e9 04 ff ff ff       	jmp    8017ef <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ee:	8d 50 04             	lea    0x4(%eax),%edx
  8018f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f4:	8b 00                	mov    (%eax),%eax
  8018f6:	99                   	cltd   
  8018f7:	31 d0                	xor    %edx,%eax
  8018f9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018fb:	83 f8 0f             	cmp    $0xf,%eax
  8018fe:	7f 0b                	jg     80190b <vprintfmt+0x142>
  801900:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  801907:	85 d2                	test   %edx,%edx
  801909:	75 18                	jne    801923 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80190b:	50                   	push   %eax
  80190c:	68 d3 24 80 00       	push   $0x8024d3
  801911:	53                   	push   %ebx
  801912:	56                   	push   %esi
  801913:	e8 94 fe ff ff       	call   8017ac <printfmt>
  801918:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80191e:	e9 cc fe ff ff       	jmp    8017ef <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801923:	52                   	push   %edx
  801924:	68 12 24 80 00       	push   $0x802412
  801929:	53                   	push   %ebx
  80192a:	56                   	push   %esi
  80192b:	e8 7c fe ff ff       	call   8017ac <printfmt>
  801930:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801936:	e9 b4 fe ff ff       	jmp    8017ef <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80193b:	8b 45 14             	mov    0x14(%ebp),%eax
  80193e:	8d 50 04             	lea    0x4(%eax),%edx
  801941:	89 55 14             	mov    %edx,0x14(%ebp)
  801944:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801946:	85 ff                	test   %edi,%edi
  801948:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  80194d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801950:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801954:	0f 8e 94 00 00 00    	jle    8019ee <vprintfmt+0x225>
  80195a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80195e:	0f 84 98 00 00 00    	je     8019fc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	ff 75 d0             	pushl  -0x30(%ebp)
  80196a:	57                   	push   %edi
  80196b:	e8 86 02 00 00       	call   801bf6 <strnlen>
  801970:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801973:	29 c1                	sub    %eax,%ecx
  801975:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801978:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80197b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80197f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801982:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801985:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801987:	eb 0f                	jmp    801998 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	53                   	push   %ebx
  80198d:	ff 75 e0             	pushl  -0x20(%ebp)
  801990:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801992:	83 ef 01             	sub    $0x1,%edi
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 ff                	test   %edi,%edi
  80199a:	7f ed                	jg     801989 <vprintfmt+0x1c0>
  80199c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80199f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019a2:	85 c9                	test   %ecx,%ecx
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a9:	0f 49 c1             	cmovns %ecx,%eax
  8019ac:	29 c1                	sub    %eax,%ecx
  8019ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b7:	89 cb                	mov    %ecx,%ebx
  8019b9:	eb 4d                	jmp    801a08 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019bf:	74 1b                	je     8019dc <vprintfmt+0x213>
  8019c1:	0f be c0             	movsbl %al,%eax
  8019c4:	83 e8 20             	sub    $0x20,%eax
  8019c7:	83 f8 5e             	cmp    $0x5e,%eax
  8019ca:	76 10                	jbe    8019dc <vprintfmt+0x213>
					putch('?', putdat);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	6a 3f                	push   $0x3f
  8019d4:	ff 55 08             	call   *0x8(%ebp)
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	eb 0d                	jmp    8019e9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	52                   	push   %edx
  8019e3:	ff 55 08             	call   *0x8(%ebp)
  8019e6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019e9:	83 eb 01             	sub    $0x1,%ebx
  8019ec:	eb 1a                	jmp    801a08 <vprintfmt+0x23f>
  8019ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8019f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019fa:	eb 0c                	jmp    801a08 <vprintfmt+0x23f>
  8019fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a02:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a05:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a08:	83 c7 01             	add    $0x1,%edi
  801a0b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a0f:	0f be d0             	movsbl %al,%edx
  801a12:	85 d2                	test   %edx,%edx
  801a14:	74 23                	je     801a39 <vprintfmt+0x270>
  801a16:	85 f6                	test   %esi,%esi
  801a18:	78 a1                	js     8019bb <vprintfmt+0x1f2>
  801a1a:	83 ee 01             	sub    $0x1,%esi
  801a1d:	79 9c                	jns    8019bb <vprintfmt+0x1f2>
  801a1f:	89 df                	mov    %ebx,%edi
  801a21:	8b 75 08             	mov    0x8(%ebp),%esi
  801a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a27:	eb 18                	jmp    801a41 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	6a 20                	push   $0x20
  801a2f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a31:	83 ef 01             	sub    $0x1,%edi
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	eb 08                	jmp    801a41 <vprintfmt+0x278>
  801a39:	89 df                	mov    %ebx,%edi
  801a3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a41:	85 ff                	test   %edi,%edi
  801a43:	7f e4                	jg     801a29 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a48:	e9 a2 fd ff ff       	jmp    8017ef <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a4d:	83 fa 01             	cmp    $0x1,%edx
  801a50:	7e 16                	jle    801a68 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a52:	8b 45 14             	mov    0x14(%ebp),%eax
  801a55:	8d 50 08             	lea    0x8(%eax),%edx
  801a58:	89 55 14             	mov    %edx,0x14(%ebp)
  801a5b:	8b 50 04             	mov    0x4(%eax),%edx
  801a5e:	8b 00                	mov    (%eax),%eax
  801a60:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a63:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a66:	eb 32                	jmp    801a9a <vprintfmt+0x2d1>
	else if (lflag)
  801a68:	85 d2                	test   %edx,%edx
  801a6a:	74 18                	je     801a84 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	8d 50 04             	lea    0x4(%eax),%edx
  801a72:	89 55 14             	mov    %edx,0x14(%ebp)
  801a75:	8b 00                	mov    (%eax),%eax
  801a77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7a:	89 c1                	mov    %eax,%ecx
  801a7c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a7f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a82:	eb 16                	jmp    801a9a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a84:	8b 45 14             	mov    0x14(%ebp),%eax
  801a87:	8d 50 04             	lea    0x4(%eax),%edx
  801a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a8d:	8b 00                	mov    (%eax),%eax
  801a8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a92:	89 c1                	mov    %eax,%ecx
  801a94:	c1 f9 1f             	sar    $0x1f,%ecx
  801a97:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a9a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aa0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aa5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801aa9:	79 74                	jns    801b1f <vprintfmt+0x356>
				putch('-', putdat);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	6a 2d                	push   $0x2d
  801ab1:	ff d6                	call   *%esi
				num = -(long long) num;
  801ab3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ab9:	f7 d8                	neg    %eax
  801abb:	83 d2 00             	adc    $0x0,%edx
  801abe:	f7 da                	neg    %edx
  801ac0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ac3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ac8:	eb 55                	jmp    801b1f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aca:	8d 45 14             	lea    0x14(%ebp),%eax
  801acd:	e8 83 fc ff ff       	call   801755 <getuint>
			base = 10;
  801ad2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ad7:	eb 46                	jmp    801b1f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ad9:	8d 45 14             	lea    0x14(%ebp),%eax
  801adc:	e8 74 fc ff ff       	call   801755 <getuint>
                        base = 8;
  801ae1:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ae6:	eb 37                	jmp    801b1f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	53                   	push   %ebx
  801aec:	6a 30                	push   $0x30
  801aee:	ff d6                	call   *%esi
			putch('x', putdat);
  801af0:	83 c4 08             	add    $0x8,%esp
  801af3:	53                   	push   %ebx
  801af4:	6a 78                	push   $0x78
  801af6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801af8:	8b 45 14             	mov    0x14(%ebp),%eax
  801afb:	8d 50 04             	lea    0x4(%eax),%edx
  801afe:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b01:	8b 00                	mov    (%eax),%eax
  801b03:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b08:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b0b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b10:	eb 0d                	jmp    801b1f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b12:	8d 45 14             	lea    0x14(%ebp),%eax
  801b15:	e8 3b fc ff ff       	call   801755 <getuint>
			base = 16;
  801b1a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b26:	57                   	push   %edi
  801b27:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2a:	51                   	push   %ecx
  801b2b:	52                   	push   %edx
  801b2c:	50                   	push   %eax
  801b2d:	89 da                	mov    %ebx,%edx
  801b2f:	89 f0                	mov    %esi,%eax
  801b31:	e8 70 fb ff ff       	call   8016a6 <printnum>
			break;
  801b36:	83 c4 20             	add    $0x20,%esp
  801b39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b3c:	e9 ae fc ff ff       	jmp    8017ef <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b41:	83 ec 08             	sub    $0x8,%esp
  801b44:	53                   	push   %ebx
  801b45:	51                   	push   %ecx
  801b46:	ff d6                	call   *%esi
			break;
  801b48:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b4e:	e9 9c fc ff ff       	jmp    8017ef <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	53                   	push   %ebx
  801b57:	6a 25                	push   $0x25
  801b59:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	eb 03                	jmp    801b63 <vprintfmt+0x39a>
  801b60:	83 ef 01             	sub    $0x1,%edi
  801b63:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b67:	75 f7                	jne    801b60 <vprintfmt+0x397>
  801b69:	e9 81 fc ff ff       	jmp    8017ef <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 18             	sub    $0x18,%esp
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b85:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b93:	85 c0                	test   %eax,%eax
  801b95:	74 26                	je     801bbd <vsnprintf+0x47>
  801b97:	85 d2                	test   %edx,%edx
  801b99:	7e 22                	jle    801bbd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b9b:	ff 75 14             	pushl  0x14(%ebp)
  801b9e:	ff 75 10             	pushl  0x10(%ebp)
  801ba1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ba4:	50                   	push   %eax
  801ba5:	68 8f 17 80 00       	push   $0x80178f
  801baa:	e8 1a fc ff ff       	call   8017c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bb2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	eb 05                	jmp    801bc2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bcd:	50                   	push   %eax
  801bce:	ff 75 10             	pushl  0x10(%ebp)
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	ff 75 08             	pushl  0x8(%ebp)
  801bd7:	e8 9a ff ff ff       	call   801b76 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
  801be9:	eb 03                	jmp    801bee <strlen+0x10>
		n++;
  801beb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bf2:	75 f7                	jne    801beb <strlen+0xd>
		n++;
	return n;
}
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bff:	ba 00 00 00 00       	mov    $0x0,%edx
  801c04:	eb 03                	jmp    801c09 <strnlen+0x13>
		n++;
  801c06:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c09:	39 c2                	cmp    %eax,%edx
  801c0b:	74 08                	je     801c15 <strnlen+0x1f>
  801c0d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c11:	75 f3                	jne    801c06 <strnlen+0x10>
  801c13:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	53                   	push   %ebx
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	83 c2 01             	add    $0x1,%edx
  801c26:	83 c1 01             	add    $0x1,%ecx
  801c29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c30:	84 db                	test   %bl,%bl
  801c32:	75 ef                	jne    801c23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c34:	5b                   	pop    %ebx
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	53                   	push   %ebx
  801c3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c3e:	53                   	push   %ebx
  801c3f:	e8 9a ff ff ff       	call   801bde <strlen>
  801c44:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c47:	ff 75 0c             	pushl  0xc(%ebp)
  801c4a:	01 d8                	add    %ebx,%eax
  801c4c:	50                   	push   %eax
  801c4d:	e8 c5 ff ff ff       	call   801c17 <strcpy>
	return dst;
}
  801c52:	89 d8                	mov    %ebx,%eax
  801c54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c64:	89 f3                	mov    %esi,%ebx
  801c66:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c69:	89 f2                	mov    %esi,%edx
  801c6b:	eb 0f                	jmp    801c7c <strncpy+0x23>
		*dst++ = *src;
  801c6d:	83 c2 01             	add    $0x1,%edx
  801c70:	0f b6 01             	movzbl (%ecx),%eax
  801c73:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c76:	80 39 01             	cmpb   $0x1,(%ecx)
  801c79:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c7c:	39 da                	cmp    %ebx,%edx
  801c7e:	75 ed                	jne    801c6d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c80:	89 f0                	mov    %esi,%eax
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	56                   	push   %esi
  801c8a:	53                   	push   %ebx
  801c8b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c91:	8b 55 10             	mov    0x10(%ebp),%edx
  801c94:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c96:	85 d2                	test   %edx,%edx
  801c98:	74 21                	je     801cbb <strlcpy+0x35>
  801c9a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c9e:	89 f2                	mov    %esi,%edx
  801ca0:	eb 09                	jmp    801cab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ca2:	83 c2 01             	add    $0x1,%edx
  801ca5:	83 c1 01             	add    $0x1,%ecx
  801ca8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cab:	39 c2                	cmp    %eax,%edx
  801cad:	74 09                	je     801cb8 <strlcpy+0x32>
  801caf:	0f b6 19             	movzbl (%ecx),%ebx
  801cb2:	84 db                	test   %bl,%bl
  801cb4:	75 ec                	jne    801ca2 <strlcpy+0x1c>
  801cb6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cb8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cbb:	29 f0                	sub    %esi,%eax
}
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cca:	eb 06                	jmp    801cd2 <strcmp+0x11>
		p++, q++;
  801ccc:	83 c1 01             	add    $0x1,%ecx
  801ccf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cd2:	0f b6 01             	movzbl (%ecx),%eax
  801cd5:	84 c0                	test   %al,%al
  801cd7:	74 04                	je     801cdd <strcmp+0x1c>
  801cd9:	3a 02                	cmp    (%edx),%al
  801cdb:	74 ef                	je     801ccc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cdd:	0f b6 c0             	movzbl %al,%eax
  801ce0:	0f b6 12             	movzbl (%edx),%edx
  801ce3:	29 d0                	sub    %edx,%eax
}
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	53                   	push   %ebx
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cf6:	eb 06                	jmp    801cfe <strncmp+0x17>
		n--, p++, q++;
  801cf8:	83 c0 01             	add    $0x1,%eax
  801cfb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cfe:	39 d8                	cmp    %ebx,%eax
  801d00:	74 15                	je     801d17 <strncmp+0x30>
  801d02:	0f b6 08             	movzbl (%eax),%ecx
  801d05:	84 c9                	test   %cl,%cl
  801d07:	74 04                	je     801d0d <strncmp+0x26>
  801d09:	3a 0a                	cmp    (%edx),%cl
  801d0b:	74 eb                	je     801cf8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d0d:	0f b6 00             	movzbl (%eax),%eax
  801d10:	0f b6 12             	movzbl (%edx),%edx
  801d13:	29 d0                	sub    %edx,%eax
  801d15:	eb 05                	jmp    801d1c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d1c:	5b                   	pop    %ebx
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d29:	eb 07                	jmp    801d32 <strchr+0x13>
		if (*s == c)
  801d2b:	38 ca                	cmp    %cl,%dl
  801d2d:	74 0f                	je     801d3e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d2f:	83 c0 01             	add    $0x1,%eax
  801d32:	0f b6 10             	movzbl (%eax),%edx
  801d35:	84 d2                	test   %dl,%dl
  801d37:	75 f2                	jne    801d2b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
  801d46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d4a:	eb 03                	jmp    801d4f <strfind+0xf>
  801d4c:	83 c0 01             	add    $0x1,%eax
  801d4f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d52:	38 ca                	cmp    %cl,%dl
  801d54:	74 04                	je     801d5a <strfind+0x1a>
  801d56:	84 d2                	test   %dl,%dl
  801d58:	75 f2                	jne    801d4c <strfind+0xc>
			break;
	return (char *) s;
}
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	57                   	push   %edi
  801d60:	56                   	push   %esi
  801d61:	53                   	push   %ebx
  801d62:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d68:	85 c9                	test   %ecx,%ecx
  801d6a:	74 36                	je     801da2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d6c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d72:	75 28                	jne    801d9c <memset+0x40>
  801d74:	f6 c1 03             	test   $0x3,%cl
  801d77:	75 23                	jne    801d9c <memset+0x40>
		c &= 0xFF;
  801d79:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	c1 e3 08             	shl    $0x8,%ebx
  801d82:	89 d6                	mov    %edx,%esi
  801d84:	c1 e6 18             	shl    $0x18,%esi
  801d87:	89 d0                	mov    %edx,%eax
  801d89:	c1 e0 10             	shl    $0x10,%eax
  801d8c:	09 f0                	or     %esi,%eax
  801d8e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	09 d0                	or     %edx,%eax
  801d94:	c1 e9 02             	shr    $0x2,%ecx
  801d97:	fc                   	cld    
  801d98:	f3 ab                	rep stos %eax,%es:(%edi)
  801d9a:	eb 06                	jmp    801da2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	fc                   	cld    
  801da0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801da2:	89 f8                	mov    %edi,%eax
  801da4:	5b                   	pop    %ebx
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	57                   	push   %edi
  801dad:	56                   	push   %esi
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801db4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801db7:	39 c6                	cmp    %eax,%esi
  801db9:	73 35                	jae    801df0 <memmove+0x47>
  801dbb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dbe:	39 d0                	cmp    %edx,%eax
  801dc0:	73 2e                	jae    801df0 <memmove+0x47>
		s += n;
		d += n;
  801dc2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dc5:	89 d6                	mov    %edx,%esi
  801dc7:	09 fe                	or     %edi,%esi
  801dc9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dcf:	75 13                	jne    801de4 <memmove+0x3b>
  801dd1:	f6 c1 03             	test   $0x3,%cl
  801dd4:	75 0e                	jne    801de4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801dd6:	83 ef 04             	sub    $0x4,%edi
  801dd9:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ddc:	c1 e9 02             	shr    $0x2,%ecx
  801ddf:	fd                   	std    
  801de0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801de2:	eb 09                	jmp    801ded <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801de4:	83 ef 01             	sub    $0x1,%edi
  801de7:	8d 72 ff             	lea    -0x1(%edx),%esi
  801dea:	fd                   	std    
  801deb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ded:	fc                   	cld    
  801dee:	eb 1d                	jmp    801e0d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801df0:	89 f2                	mov    %esi,%edx
  801df2:	09 c2                	or     %eax,%edx
  801df4:	f6 c2 03             	test   $0x3,%dl
  801df7:	75 0f                	jne    801e08 <memmove+0x5f>
  801df9:	f6 c1 03             	test   $0x3,%cl
  801dfc:	75 0a                	jne    801e08 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dfe:	c1 e9 02             	shr    $0x2,%ecx
  801e01:	89 c7                	mov    %eax,%edi
  801e03:	fc                   	cld    
  801e04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e06:	eb 05                	jmp    801e0d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e08:	89 c7                	mov    %eax,%edi
  801e0a:	fc                   	cld    
  801e0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e14:	ff 75 10             	pushl  0x10(%ebp)
  801e17:	ff 75 0c             	pushl  0xc(%ebp)
  801e1a:	ff 75 08             	pushl  0x8(%ebp)
  801e1d:	e8 87 ff ff ff       	call   801da9 <memmove>
}
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e34:	eb 1a                	jmp    801e50 <memcmp+0x2c>
		if (*s1 != *s2)
  801e36:	0f b6 08             	movzbl (%eax),%ecx
  801e39:	0f b6 1a             	movzbl (%edx),%ebx
  801e3c:	38 d9                	cmp    %bl,%cl
  801e3e:	74 0a                	je     801e4a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e40:	0f b6 c1             	movzbl %cl,%eax
  801e43:	0f b6 db             	movzbl %bl,%ebx
  801e46:	29 d8                	sub    %ebx,%eax
  801e48:	eb 0f                	jmp    801e59 <memcmp+0x35>
		s1++, s2++;
  801e4a:	83 c0 01             	add    $0x1,%eax
  801e4d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e50:	39 f0                	cmp    %esi,%eax
  801e52:	75 e2                	jne    801e36 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	53                   	push   %ebx
  801e61:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e64:	89 c1                	mov    %eax,%ecx
  801e66:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e69:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e6d:	eb 0a                	jmp    801e79 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e6f:	0f b6 10             	movzbl (%eax),%edx
  801e72:	39 da                	cmp    %ebx,%edx
  801e74:	74 07                	je     801e7d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e76:	83 c0 01             	add    $0x1,%eax
  801e79:	39 c8                	cmp    %ecx,%eax
  801e7b:	72 f2                	jb     801e6f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e7d:	5b                   	pop    %ebx
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e8c:	eb 03                	jmp    801e91 <strtol+0x11>
		s++;
  801e8e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e91:	0f b6 01             	movzbl (%ecx),%eax
  801e94:	3c 20                	cmp    $0x20,%al
  801e96:	74 f6                	je     801e8e <strtol+0xe>
  801e98:	3c 09                	cmp    $0x9,%al
  801e9a:	74 f2                	je     801e8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e9c:	3c 2b                	cmp    $0x2b,%al
  801e9e:	75 0a                	jne    801eaa <strtol+0x2a>
		s++;
  801ea0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ea3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ea8:	eb 11                	jmp    801ebb <strtol+0x3b>
  801eaa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801eaf:	3c 2d                	cmp    $0x2d,%al
  801eb1:	75 08                	jne    801ebb <strtol+0x3b>
		s++, neg = 1;
  801eb3:	83 c1 01             	add    $0x1,%ecx
  801eb6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ebb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ec1:	75 15                	jne    801ed8 <strtol+0x58>
  801ec3:	80 39 30             	cmpb   $0x30,(%ecx)
  801ec6:	75 10                	jne    801ed8 <strtol+0x58>
  801ec8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ecc:	75 7c                	jne    801f4a <strtol+0xca>
		s += 2, base = 16;
  801ece:	83 c1 02             	add    $0x2,%ecx
  801ed1:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ed6:	eb 16                	jmp    801eee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ed8:	85 db                	test   %ebx,%ebx
  801eda:	75 12                	jne    801eee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801edc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ee1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee4:	75 08                	jne    801eee <strtol+0x6e>
		s++, base = 8;
  801ee6:	83 c1 01             	add    $0x1,%ecx
  801ee9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ef6:	0f b6 11             	movzbl (%ecx),%edx
  801ef9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801efc:	89 f3                	mov    %esi,%ebx
  801efe:	80 fb 09             	cmp    $0x9,%bl
  801f01:	77 08                	ja     801f0b <strtol+0x8b>
			dig = *s - '0';
  801f03:	0f be d2             	movsbl %dl,%edx
  801f06:	83 ea 30             	sub    $0x30,%edx
  801f09:	eb 22                	jmp    801f2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f0e:	89 f3                	mov    %esi,%ebx
  801f10:	80 fb 19             	cmp    $0x19,%bl
  801f13:	77 08                	ja     801f1d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f15:	0f be d2             	movsbl %dl,%edx
  801f18:	83 ea 57             	sub    $0x57,%edx
  801f1b:	eb 10                	jmp    801f2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f20:	89 f3                	mov    %esi,%ebx
  801f22:	80 fb 19             	cmp    $0x19,%bl
  801f25:	77 16                	ja     801f3d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f27:	0f be d2             	movsbl %dl,%edx
  801f2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f30:	7d 0b                	jge    801f3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f32:	83 c1 01             	add    $0x1,%ecx
  801f35:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f3b:	eb b9                	jmp    801ef6 <strtol+0x76>

	if (endptr)
  801f3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f41:	74 0d                	je     801f50 <strtol+0xd0>
		*endptr = (char *) s;
  801f43:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f46:	89 0e                	mov    %ecx,(%esi)
  801f48:	eb 06                	jmp    801f50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	74 98                	je     801ee6 <strtol+0x66>
  801f4e:	eb 9e                	jmp    801eee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	f7 da                	neg    %edx
  801f54:	85 ff                	test   %edi,%edi
  801f56:	0f 45 c2             	cmovne %edx,%eax
}
  801f59:	5b                   	pop    %ebx
  801f5a:	5e                   	pop    %esi
  801f5b:	5f                   	pop    %edi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	8b 75 08             	mov    0x8(%ebp),%esi
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f6c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f6e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f73:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	50                   	push   %eax
  801f7a:	e8 9b e3 ff ff       	call   80031a <sys_ipc_recv>

	if (r < 0) {
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	79 16                	jns    801f9c <ipc_recv+0x3e>
		if (from_env_store)
  801f86:	85 f6                	test   %esi,%esi
  801f88:	74 06                	je     801f90 <ipc_recv+0x32>
			*from_env_store = 0;
  801f8a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f90:	85 db                	test   %ebx,%ebx
  801f92:	74 2c                	je     801fc0 <ipc_recv+0x62>
			*perm_store = 0;
  801f94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f9a:	eb 24                	jmp    801fc0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f9c:	85 f6                	test   %esi,%esi
  801f9e:	74 0a                	je     801faa <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801fa0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa5:	8b 40 74             	mov    0x74(%eax),%eax
  801fa8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801faa:	85 db                	test   %ebx,%ebx
  801fac:	74 0a                	je     801fb8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801fae:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb3:	8b 40 78             	mov    0x78(%eax),%eax
  801fb6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fb8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbd:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    

00801fc7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 0c             	sub    $0xc,%esp
  801fd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fd9:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801fdb:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fe0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801fe3:	ff 75 14             	pushl  0x14(%ebp)
  801fe6:	53                   	push   %ebx
  801fe7:	56                   	push   %esi
  801fe8:	57                   	push   %edi
  801fe9:	e8 09 e3 ff ff       	call   8002f7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff4:	75 07                	jne    801ffd <ipc_send+0x36>
			sys_yield();
  801ff6:	e8 50 e1 ff ff       	call   80014b <sys_yield>
  801ffb:	eb e6                	jmp    801fe3 <ipc_send+0x1c>
		} else if (r < 0) {
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	79 12                	jns    802013 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802001:	50                   	push   %eax
  802002:	68 c0 27 80 00       	push   $0x8027c0
  802007:	6a 51                	push   $0x51
  802009:	68 cd 27 80 00       	push   $0x8027cd
  80200e:	e8 a6 f5 ff ff       	call   8015b9 <_panic>
		}
	}
}
  802013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802021:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802026:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802029:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80202f:	8b 52 50             	mov    0x50(%edx),%edx
  802032:	39 ca                	cmp    %ecx,%edx
  802034:	75 0d                	jne    802043 <ipc_find_env+0x28>
			return envs[i].env_id;
  802036:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802039:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80203e:	8b 40 48             	mov    0x48(%eax),%eax
  802041:	eb 0f                	jmp    802052 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802043:	83 c0 01             	add    $0x1,%eax
  802046:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204b:	75 d9                	jne    802026 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    

00802054 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	c1 e8 16             	shr    $0x16,%eax
  80205f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206b:	f6 c1 01             	test   $0x1,%cl
  80206e:	74 1d                	je     80208d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802070:	c1 ea 0c             	shr    $0xc,%edx
  802073:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207a:	f6 c2 01             	test   $0x1,%dl
  80207d:	74 0e                	je     80208d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207f:	c1 ea 0c             	shr    $0xc,%edx
  802082:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802089:	ef 
  80208a:	0f b7 c0             	movzwl %ax,%eax
}
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
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
