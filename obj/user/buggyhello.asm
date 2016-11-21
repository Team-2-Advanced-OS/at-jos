
obj/user/buggyhello.debug:     file format elf32-i386


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
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
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
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 ea 1d 80 00       	push   $0x801dea
  800111:	6a 23                	push   $0x23
  800113:	68 07 1e 80 00       	push   $0x801e07
  800118:	e8 4a 0f 00 00       	call   801067 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 ea 1d 80 00       	push   $0x801dea
  800192:	6a 23                	push   $0x23
  800194:	68 07 1e 80 00       	push   $0x801e07
  800199:	e8 c9 0e 00 00       	call   801067 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 ea 1d 80 00       	push   $0x801dea
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 07 1e 80 00       	push   $0x801e07
  8001db:	e8 87 0e 00 00       	call   801067 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 ea 1d 80 00       	push   $0x801dea
  800216:	6a 23                	push   $0x23
  800218:	68 07 1e 80 00       	push   $0x801e07
  80021d:	e8 45 0e 00 00       	call   801067 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 ea 1d 80 00       	push   $0x801dea
  800258:	6a 23                	push   $0x23
  80025a:	68 07 1e 80 00       	push   $0x801e07
  80025f:	e8 03 0e 00 00       	call   801067 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 ea 1d 80 00       	push   $0x801dea
  80029a:	6a 23                	push   $0x23
  80029c:	68 07 1e 80 00       	push   $0x801e07
  8002a1:	e8 c1 0d 00 00       	call   801067 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 ea 1d 80 00       	push   $0x801dea
  8002dc:	6a 23                	push   $0x23
  8002de:	68 07 1e 80 00       	push   $0x801e07
  8002e3:	e8 7f 0d 00 00       	call   801067 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 ea 1d 80 00       	push   $0x801dea
  800340:	6a 23                	push   $0x23
  800342:	68 07 1e 80 00       	push   $0x801e07
  800347:	e8 1b 0d 00 00       	call   801067 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 18 1e 80 00       	push   $0x801e18
  80045b:	e8 e0 0c 00 00       	call   801140 <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 59 1e 80 00       	push   $0x801e59
  800685:	e8 b6 0a 00 00       	call   801140 <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 75 1e 80 00       	push   $0x801e75
  80075a:	e8 e1 09 00 00       	call   801140 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 38 1e 80 00       	push   $0x801e38
  80080f:	e8 2c 09 00 00       	call   801140 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 0c 02 00 00       	call   800ae4 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 aa 11 00 00       	call   801ac9 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 3b 11 00 00       	call   801a75 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 c5 10 00 00       	call   801a0c <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 f5 0c 00 00       	call   8016c5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 08             	sub    $0x8,%esp
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800a00:	8b 52 0c             	mov    0xc(%edx),%edx
  800a03:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a09:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a0e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a13:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a16:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a1c:	53                   	push   %ebx
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	68 08 50 80 00       	push   $0x805008
  800a25:	e8 2d 0e 00 00       	call   801857 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a34:	e8 ca fe ff ff       	call   800903 <fsipc>
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 1d                	js     800a5d <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a40:	39 d8                	cmp    %ebx,%eax
  800a42:	76 19                	jbe    800a5d <devfile_write+0x6a>
  800a44:	68 a4 1e 80 00       	push   $0x801ea4
  800a49:	68 b0 1e 80 00       	push   $0x801eb0
  800a4e:	68 a5 00 00 00       	push   $0xa5
  800a53:	68 c5 1e 80 00       	push   $0x801ec5
  800a58:	e8 0a 06 00 00       	call   801067 <_panic>
	return r;
}
  800a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a75:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a80:	b8 03 00 00 00       	mov    $0x3,%eax
  800a85:	e8 79 fe ff ff       	call   800903 <fsipc>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 4b                	js     800adb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a90:	39 c6                	cmp    %eax,%esi
  800a92:	73 16                	jae    800aaa <devfile_read+0x48>
  800a94:	68 d0 1e 80 00       	push   $0x801ed0
  800a99:	68 b0 1e 80 00       	push   $0x801eb0
  800a9e:	6a 7c                	push   $0x7c
  800aa0:	68 c5 1e 80 00       	push   $0x801ec5
  800aa5:	e8 bd 05 00 00       	call   801067 <_panic>
	assert(r <= PGSIZE);
  800aaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aaf:	7e 16                	jle    800ac7 <devfile_read+0x65>
  800ab1:	68 d7 1e 80 00       	push   $0x801ed7
  800ab6:	68 b0 1e 80 00       	push   $0x801eb0
  800abb:	6a 7d                	push   $0x7d
  800abd:	68 c5 1e 80 00       	push   $0x801ec5
  800ac2:	e8 a0 05 00 00       	call   801067 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac7:	83 ec 04             	sub    $0x4,%esp
  800aca:	50                   	push   %eax
  800acb:	68 00 50 80 00       	push   $0x805000
  800ad0:	ff 75 0c             	pushl  0xc(%ebp)
  800ad3:	e8 7f 0d 00 00       	call   801857 <memmove>
	return r;
  800ad8:	83 c4 10             	add    $0x10,%esp
}
  800adb:	89 d8                	mov    %ebx,%eax
  800add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 20             	sub    $0x20,%esp
  800aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aee:	53                   	push   %ebx
  800aef:	e8 98 0b 00 00       	call   80168c <strlen>
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afc:	7f 67                	jg     800b65 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	e8 71 f8 ff ff       	call   80037b <fd_alloc>
  800b0a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 57                	js     800b6a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	68 00 50 80 00       	push   $0x805000
  800b1c:	e8 a4 0b 00 00       	call   8016c5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b31:	e8 cd fd ff ff       	call   800903 <fsipc>
  800b36:	89 c3                	mov    %eax,%ebx
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	79 14                	jns    800b53 <open+0x6f>
		fd_close(fd, 0);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	6a 00                	push   $0x0
  800b44:	ff 75 f4             	pushl  -0xc(%ebp)
  800b47:	e8 27 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	89 da                	mov    %ebx,%edx
  800b51:	eb 17                	jmp    800b6a <open+0x86>
	}

	return fd2num(fd);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 f6 f7 ff ff       	call   800354 <fd2num>
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	eb 05                	jmp    800b6a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b65:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6a:	89 d0                	mov    %edx,%eax
  800b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b81:	e8 7d fd ff ff       	call   800903 <fsipc>
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 08             	pushl  0x8(%ebp)
  800b96:	e8 c9 f7 ff ff       	call   800364 <fd2data>
  800b9b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9d:	83 c4 08             	add    $0x8,%esp
  800ba0:	68 e3 1e 80 00       	push   $0x801ee3
  800ba5:	53                   	push   %ebx
  800ba6:	e8 1a 0b 00 00       	call   8016c5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bab:	8b 46 04             	mov    0x4(%esi),%eax
  800bae:	2b 06                	sub    (%esi),%eax
  800bb0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbd:	00 00 00 
	stat->st_dev = &devpipe;
  800bc0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc7:	30 80 00 
	return 0;
}
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be0:	53                   	push   %ebx
  800be1:	6a 00                	push   $0x0
  800be3:	e8 00 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be8:	89 1c 24             	mov    %ebx,(%esp)
  800beb:	e8 74 f7 ff ff       	call   800364 <fd2data>
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 00                	push   $0x0
  800bf6:	e8 ed f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 1c             	sub    $0x1c,%esp
  800c09:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c0c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0e:	a1 04 40 80 00       	mov    0x804004,%eax
  800c13:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1c:	e8 e1 0e 00 00       	call   801b02 <pageref>
  800c21:	89 c3                	mov    %eax,%ebx
  800c23:	89 3c 24             	mov    %edi,(%esp)
  800c26:	e8 d7 0e 00 00       	call   801b02 <pageref>
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	39 c3                	cmp    %eax,%ebx
  800c30:	0f 94 c1             	sete   %cl
  800c33:	0f b6 c9             	movzbl %cl,%ecx
  800c36:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c39:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c3f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c42:	39 ce                	cmp    %ecx,%esi
  800c44:	74 1b                	je     800c61 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c46:	39 c3                	cmp    %eax,%ebx
  800c48:	75 c4                	jne    800c0e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4a:	8b 42 58             	mov    0x58(%edx),%eax
  800c4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c50:	50                   	push   %eax
  800c51:	56                   	push   %esi
  800c52:	68 ea 1e 80 00       	push   $0x801eea
  800c57:	e8 e4 04 00 00       	call   801140 <cprintf>
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	eb ad                	jmp    800c0e <_pipeisclosed+0xe>
	}
}
  800c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 28             	sub    $0x28,%esp
  800c75:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c78:	56                   	push   %esi
  800c79:	e8 e6 f6 ff ff       	call   800364 <fd2data>
  800c7e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c80:	83 c4 10             	add    $0x10,%esp
  800c83:	bf 00 00 00 00       	mov    $0x0,%edi
  800c88:	eb 4b                	jmp    800cd5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c8a:	89 da                	mov    %ebx,%edx
  800c8c:	89 f0                	mov    %esi,%eax
  800c8e:	e8 6d ff ff ff       	call   800c00 <_pipeisclosed>
  800c93:	85 c0                	test   %eax,%eax
  800c95:	75 48                	jne    800cdf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c97:	e8 a8 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c9c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9f:	8b 0b                	mov    (%ebx),%ecx
  800ca1:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca4:	39 d0                	cmp    %edx,%eax
  800ca6:	73 e2                	jae    800c8a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800caf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb2:	89 c2                	mov    %eax,%edx
  800cb4:	c1 fa 1f             	sar    $0x1f,%edx
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cbf:	83 e2 1f             	and    $0x1f,%edx
  800cc2:	29 ca                	sub    %ecx,%edx
  800cc4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ccc:	83 c0 01             	add    $0x1,%eax
  800ccf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd2:	83 c7 01             	add    $0x1,%edi
  800cd5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd8:	75 c2                	jne    800c9c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cda:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdd:	eb 05                	jmp    800ce4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 18             	sub    $0x18,%esp
  800cf5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf8:	57                   	push   %edi
  800cf9:	e8 66 f6 ff ff       	call   800364 <fd2data>
  800cfe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d00:	83 c4 10             	add    $0x10,%esp
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	eb 3d                	jmp    800d47 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d0a:	85 db                	test   %ebx,%ebx
  800d0c:	74 04                	je     800d12 <devpipe_read+0x26>
				return i;
  800d0e:	89 d8                	mov    %ebx,%eax
  800d10:	eb 44                	jmp    800d56 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	e8 e5 fe ff ff       	call   800c00 <_pipeisclosed>
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	75 32                	jne    800d51 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1f:	e8 20 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d24:	8b 06                	mov    (%esi),%eax
  800d26:	3b 46 04             	cmp    0x4(%esi),%eax
  800d29:	74 df                	je     800d0a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2b:	99                   	cltd   
  800d2c:	c1 ea 1b             	shr    $0x1b,%edx
  800d2f:	01 d0                	add    %edx,%eax
  800d31:	83 e0 1f             	and    $0x1f,%eax
  800d34:	29 d0                	sub    %edx,%eax
  800d36:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d41:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d44:	83 c3 01             	add    $0x1,%ebx
  800d47:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d4a:	75 d8                	jne    800d24 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4f:	eb 05                	jmp    800d56 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d69:	50                   	push   %eax
  800d6a:	e8 0c f6 ff ff       	call   80037b <fd_alloc>
  800d6f:	83 c4 10             	add    $0x10,%esp
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	85 c0                	test   %eax,%eax
  800d76:	0f 88 2c 01 00 00    	js     800ea8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7c:	83 ec 04             	sub    $0x4,%esp
  800d7f:	68 07 04 00 00       	push   $0x407
  800d84:	ff 75 f4             	pushl  -0xc(%ebp)
  800d87:	6a 00                	push   $0x0
  800d89:	e8 d5 f3 ff ff       	call   800163 <sys_page_alloc>
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	85 c0                	test   %eax,%eax
  800d95:	0f 88 0d 01 00 00    	js     800ea8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da1:	50                   	push   %eax
  800da2:	e8 d4 f5 ff ff       	call   80037b <fd_alloc>
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	0f 88 e2 00 00 00    	js     800e96 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	68 07 04 00 00       	push   $0x407
  800dbc:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbf:	6a 00                	push   $0x0
  800dc1:	e8 9d f3 ff ff       	call   800163 <sys_page_alloc>
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	0f 88 c3 00 00 00    	js     800e96 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd9:	e8 86 f5 ff ff       	call   800364 <fd2data>
  800dde:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de0:	83 c4 0c             	add    $0xc,%esp
  800de3:	68 07 04 00 00       	push   $0x407
  800de8:	50                   	push   %eax
  800de9:	6a 00                	push   $0x0
  800deb:	e8 73 f3 ff ff       	call   800163 <sys_page_alloc>
  800df0:	89 c3                	mov    %eax,%ebx
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	0f 88 89 00 00 00    	js     800e86 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	ff 75 f0             	pushl  -0x10(%ebp)
  800e03:	e8 5c f5 ff ff       	call   800364 <fd2data>
  800e08:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0f:	50                   	push   %eax
  800e10:	6a 00                	push   $0x0
  800e12:	56                   	push   %esi
  800e13:	6a 00                	push   $0x0
  800e15:	e8 8c f3 ff ff       	call   8001a6 <sys_page_map>
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	83 c4 20             	add    $0x20,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 55                	js     800e78 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	ff 75 f4             	pushl  -0xc(%ebp)
  800e53:	e8 fc f4 ff ff       	call   800354 <fd2num>
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5d:	83 c4 04             	add    $0x4,%esp
  800e60:	ff 75 f0             	pushl  -0x10(%ebp)
  800e63:	e8 ec f4 ff ff       	call   800354 <fd2num>
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	ba 00 00 00 00       	mov    $0x0,%edx
  800e76:	eb 30                	jmp    800ea8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	56                   	push   %esi
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 65 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e83:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8c:	6a 00                	push   $0x0
  800e8e:	e8 55 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e93:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 45 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea8:	89 d0                	mov    %edx,%eax
  800eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	ff 75 08             	pushl  0x8(%ebp)
  800ebe:	e8 07 f5 ff ff       	call   8003ca <fd_lookup>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 18                	js     800ee2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed0:	e8 8f f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eda:	e8 21 fd ff ff       	call   800c00 <_pipeisclosed>
  800edf:	83 c4 10             	add    $0x10,%esp
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef4:	68 02 1f 80 00       	push   $0x801f02
  800ef9:	ff 75 0c             	pushl  0xc(%ebp)
  800efc:	e8 c4 07 00 00       	call   8016c5 <strcpy>
	return 0;
}
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f14:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f19:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1f:	eb 2d                	jmp    800f4e <devcons_write+0x46>
		m = n - tot;
  800f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f24:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f26:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f29:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f2e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f31:	83 ec 04             	sub    $0x4,%esp
  800f34:	53                   	push   %ebx
  800f35:	03 45 0c             	add    0xc(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	57                   	push   %edi
  800f3a:	e8 18 09 00 00       	call   801857 <memmove>
		sys_cputs(buf, m);
  800f3f:	83 c4 08             	add    $0x8,%esp
  800f42:	53                   	push   %ebx
  800f43:	57                   	push   %edi
  800f44:	e8 5e f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f49:	01 de                	add    %ebx,%esi
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f53:	72 cc                	jb     800f21 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6c:	74 2a                	je     800f98 <devcons_read+0x3b>
  800f6e:	eb 05                	jmp    800f75 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f70:	e8 cf f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f75:	e8 4b f1 ff ff       	call   8000c5 <sys_cgetc>
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	74 f2                	je     800f70 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 16                	js     800f98 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f82:	83 f8 04             	cmp    $0x4,%eax
  800f85:	74 0c                	je     800f93 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	88 02                	mov    %al,(%edx)
	return 1;
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f91:	eb 05                	jmp    800f98 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa6:	6a 01                	push   $0x1
  800fa8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	e8 f6 f0 ff ff       	call   8000a7 <sys_cputs>
}
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <getchar>:

int
getchar(void)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fbc:	6a 01                	push   $0x1
  800fbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 67 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 0f                	js     800fdf <getchar+0x29>
		return r;
	if (r < 1)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	7e 06                	jle    800fda <getchar+0x24>
		return -E_EOF;
	return c;
  800fd4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd8:	eb 05                	jmp    800fdf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fda:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	ff 75 08             	pushl  0x8(%ebp)
  800fee:	e8 d7 f3 ff ff       	call   8003ca <fd_lookup>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 11                	js     80100b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801003:	39 10                	cmp    %edx,(%eax)
  801005:	0f 94 c0             	sete   %al
  801008:	0f b6 c0             	movzbl %al,%eax
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <opencons>:

int
opencons(void)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	e8 5f f3 ff ff       	call   80037b <fd_alloc>
  80101c:	83 c4 10             	add    $0x10,%esp
		return r;
  80101f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	78 3e                	js     801063 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801025:	83 ec 04             	sub    $0x4,%esp
  801028:	68 07 04 00 00       	push   $0x407
  80102d:	ff 75 f4             	pushl  -0xc(%ebp)
  801030:	6a 00                	push   $0x0
  801032:	e8 2c f1 ff ff       	call   800163 <sys_page_alloc>
  801037:	83 c4 10             	add    $0x10,%esp
		return r;
  80103a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103c:	85 c0                	test   %eax,%eax
  80103e:	78 23                	js     801063 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801040:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	50                   	push   %eax
  801059:	e8 f6 f2 ff ff       	call   800354 <fd2num>
  80105e:	89 c2                	mov    %eax,%edx
  801060:	83 c4 10             	add    $0x10,%esp
}
  801063:	89 d0                	mov    %edx,%eax
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80106f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801075:	e8 ab f0 ff ff       	call   800125 <sys_getenvid>
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	ff 75 0c             	pushl  0xc(%ebp)
  801080:	ff 75 08             	pushl  0x8(%ebp)
  801083:	56                   	push   %esi
  801084:	50                   	push   %eax
  801085:	68 10 1f 80 00       	push   $0x801f10
  80108a:	e8 b1 00 00 00       	call   801140 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80108f:	83 c4 18             	add    $0x18,%esp
  801092:	53                   	push   %ebx
  801093:	ff 75 10             	pushl  0x10(%ebp)
  801096:	e8 54 00 00 00       	call   8010ef <vcprintf>
	cprintf("\n");
  80109b:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  8010a2:	e8 99 00 00 00       	call   801140 <cprintf>
  8010a7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010aa:	cc                   	int3   
  8010ab:	eb fd                	jmp    8010aa <_panic+0x43>

008010ad <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b7:	8b 13                	mov    (%ebx),%edx
  8010b9:	8d 42 01             	lea    0x1(%edx),%eax
  8010bc:	89 03                	mov    %eax,(%ebx)
  8010be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ca:	75 1a                	jne    8010e6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	68 ff 00 00 00       	push   $0xff
  8010d4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d7:	50                   	push   %eax
  8010d8:	e8 ca ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ff:	00 00 00 
	b.cnt = 0;
  801102:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801109:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80110c:	ff 75 0c             	pushl  0xc(%ebp)
  80110f:	ff 75 08             	pushl  0x8(%ebp)
  801112:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	68 ad 10 80 00       	push   $0x8010ad
  80111e:	e8 54 01 00 00       	call   801277 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801123:	83 c4 08             	add    $0x8,%esp
  801126:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80112c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	e8 6f ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801138:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801146:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801149:	50                   	push   %eax
  80114a:	ff 75 08             	pushl  0x8(%ebp)
  80114d:	e8 9d ff ff ff       	call   8010ef <vcprintf>
	va_end(ap);

	return cnt;
}
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 1c             	sub    $0x1c,%esp
  80115d:	89 c7                	mov    %eax,%edi
  80115f:	89 d6                	mov    %edx,%esi
  801161:	8b 45 08             	mov    0x8(%ebp),%eax
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801178:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80117b:	39 d3                	cmp    %edx,%ebx
  80117d:	72 05                	jb     801184 <printnum+0x30>
  80117f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801182:	77 45                	ja     8011c9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	ff 75 18             	pushl  0x18(%ebp)
  80118a:	8b 45 14             	mov    0x14(%ebp),%eax
  80118d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801190:	53                   	push   %ebx
  801191:	ff 75 10             	pushl  0x10(%ebp)
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119a:	ff 75 e0             	pushl  -0x20(%ebp)
  80119d:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a3:	e8 98 09 00 00       	call   801b40 <__udivdi3>
  8011a8:	83 c4 18             	add    $0x18,%esp
  8011ab:	52                   	push   %edx
  8011ac:	50                   	push   %eax
  8011ad:	89 f2                	mov    %esi,%edx
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	e8 9e ff ff ff       	call   801154 <printnum>
  8011b6:	83 c4 20             	add    $0x20,%esp
  8011b9:	eb 18                	jmp    8011d3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	56                   	push   %esi
  8011bf:	ff 75 18             	pushl  0x18(%ebp)
  8011c2:	ff d7                	call   *%edi
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb 03                	jmp    8011cc <printnum+0x78>
  8011c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011cc:	83 eb 01             	sub    $0x1,%ebx
  8011cf:	85 db                	test   %ebx,%ebx
  8011d1:	7f e8                	jg     8011bb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	56                   	push   %esi
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e6:	e8 85 0a 00 00       	call   801c70 <__umoddi3>
  8011eb:	83 c4 14             	add    $0x14,%esp
  8011ee:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011f5:	50                   	push   %eax
  8011f6:	ff d7                	call   *%edi
}
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801206:	83 fa 01             	cmp    $0x1,%edx
  801209:	7e 0e                	jle    801219 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80120b:	8b 10                	mov    (%eax),%edx
  80120d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801210:	89 08                	mov    %ecx,(%eax)
  801212:	8b 02                	mov    (%edx),%eax
  801214:	8b 52 04             	mov    0x4(%edx),%edx
  801217:	eb 22                	jmp    80123b <getuint+0x38>
	else if (lflag)
  801219:	85 d2                	test   %edx,%edx
  80121b:	74 10                	je     80122d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	ba 00 00 00 00       	mov    $0x0,%edx
  80122b:	eb 0e                	jmp    80123b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801243:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801247:	8b 10                	mov    (%eax),%edx
  801249:	3b 50 04             	cmp    0x4(%eax),%edx
  80124c:	73 0a                	jae    801258 <sprintputch+0x1b>
		*b->buf++ = ch;
  80124e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801251:	89 08                	mov    %ecx,(%eax)
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	88 02                	mov    %al,(%edx)
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801260:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801263:	50                   	push   %eax
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	ff 75 08             	pushl  0x8(%ebp)
  80126d:	e8 05 00 00 00       	call   801277 <vprintfmt>
	va_end(ap);
}
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 2c             	sub    $0x2c,%esp
  801280:	8b 75 08             	mov    0x8(%ebp),%esi
  801283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801286:	8b 7d 10             	mov    0x10(%ebp),%edi
  801289:	eb 12                	jmp    80129d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80128b:	85 c0                	test   %eax,%eax
  80128d:	0f 84 89 03 00 00    	je     80161c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	53                   	push   %ebx
  801297:	50                   	push   %eax
  801298:	ff d6                	call   *%esi
  80129a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80129d:	83 c7 01             	add    $0x1,%edi
  8012a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012a4:	83 f8 25             	cmp    $0x25,%eax
  8012a7:	75 e2                	jne    80128b <vprintfmt+0x14>
  8012a9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012ad:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012bb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c7:	eb 07                	jmp    8012d0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012cc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8d 47 01             	lea    0x1(%edi),%eax
  8012d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d6:	0f b6 07             	movzbl (%edi),%eax
  8012d9:	0f b6 c8             	movzbl %al,%ecx
  8012dc:	83 e8 23             	sub    $0x23,%eax
  8012df:	3c 55                	cmp    $0x55,%al
  8012e1:	0f 87 1a 03 00 00    	ja     801601 <vprintfmt+0x38a>
  8012e7:	0f b6 c0             	movzbl %al,%eax
  8012ea:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012f4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f8:	eb d6                	jmp    8012d0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801305:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801308:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80130c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80130f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801312:	83 fa 09             	cmp    $0x9,%edx
  801315:	77 39                	ja     801350 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801317:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80131a:	eb e9                	jmp    801305 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80131c:	8b 45 14             	mov    0x14(%ebp),%eax
  80131f:	8d 48 04             	lea    0x4(%eax),%ecx
  801322:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801325:	8b 00                	mov    (%eax),%eax
  801327:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80132d:	eb 27                	jmp    801356 <vprintfmt+0xdf>
  80132f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801332:	85 c0                	test   %eax,%eax
  801334:	b9 00 00 00 00       	mov    $0x0,%ecx
  801339:	0f 49 c8             	cmovns %eax,%ecx
  80133c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801342:	eb 8c                	jmp    8012d0 <vprintfmt+0x59>
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801347:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80134e:	eb 80                	jmp    8012d0 <vprintfmt+0x59>
  801350:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801353:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801356:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135a:	0f 89 70 ff ff ff    	jns    8012d0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801360:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801363:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801366:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80136d:	e9 5e ff ff ff       	jmp    8012d0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801372:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801378:	e9 53 ff ff ff       	jmp    8012d0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80137d:	8b 45 14             	mov    0x14(%ebp),%eax
  801380:	8d 50 04             	lea    0x4(%eax),%edx
  801383:	89 55 14             	mov    %edx,0x14(%ebp)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	53                   	push   %ebx
  80138a:	ff 30                	pushl  (%eax)
  80138c:	ff d6                	call   *%esi
			break;
  80138e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801394:	e9 04 ff ff ff       	jmp    80129d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801399:	8b 45 14             	mov    0x14(%ebp),%eax
  80139c:	8d 50 04             	lea    0x4(%eax),%edx
  80139f:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a2:	8b 00                	mov    (%eax),%eax
  8013a4:	99                   	cltd   
  8013a5:	31 d0                	xor    %edx,%eax
  8013a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a9:	83 f8 0f             	cmp    $0xf,%eax
  8013ac:	7f 0b                	jg     8013b9 <vprintfmt+0x142>
  8013ae:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013b5:	85 d2                	test   %edx,%edx
  8013b7:	75 18                	jne    8013d1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013b9:	50                   	push   %eax
  8013ba:	68 4b 1f 80 00       	push   $0x801f4b
  8013bf:	53                   	push   %ebx
  8013c0:	56                   	push   %esi
  8013c1:	e8 94 fe ff ff       	call   80125a <printfmt>
  8013c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013cc:	e9 cc fe ff ff       	jmp    80129d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013d1:	52                   	push   %edx
  8013d2:	68 c2 1e 80 00       	push   $0x801ec2
  8013d7:	53                   	push   %ebx
  8013d8:	56                   	push   %esi
  8013d9:	e8 7c fe ff ff       	call   80125a <printfmt>
  8013de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e4:	e9 b4 fe ff ff       	jmp    80129d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ec:	8d 50 04             	lea    0x4(%eax),%edx
  8013ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f4:	85 ff                	test   %edi,%edi
  8013f6:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  8013fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801402:	0f 8e 94 00 00 00    	jle    80149c <vprintfmt+0x225>
  801408:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80140c:	0f 84 98 00 00 00    	je     8014aa <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	ff 75 d0             	pushl  -0x30(%ebp)
  801418:	57                   	push   %edi
  801419:	e8 86 02 00 00       	call   8016a4 <strnlen>
  80141e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801421:	29 c1                	sub    %eax,%ecx
  801423:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801426:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801429:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80142d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801430:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801433:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801435:	eb 0f                	jmp    801446 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	53                   	push   %ebx
  80143b:	ff 75 e0             	pushl  -0x20(%ebp)
  80143e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801440:	83 ef 01             	sub    $0x1,%edi
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 ff                	test   %edi,%edi
  801448:	7f ed                	jg     801437 <vprintfmt+0x1c0>
  80144a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80144d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801450:	85 c9                	test   %ecx,%ecx
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
  801457:	0f 49 c1             	cmovns %ecx,%eax
  80145a:	29 c1                	sub    %eax,%ecx
  80145c:	89 75 08             	mov    %esi,0x8(%ebp)
  80145f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801462:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801465:	89 cb                	mov    %ecx,%ebx
  801467:	eb 4d                	jmp    8014b6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801469:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80146d:	74 1b                	je     80148a <vprintfmt+0x213>
  80146f:	0f be c0             	movsbl %al,%eax
  801472:	83 e8 20             	sub    $0x20,%eax
  801475:	83 f8 5e             	cmp    $0x5e,%eax
  801478:	76 10                	jbe    80148a <vprintfmt+0x213>
					putch('?', putdat);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	ff 75 0c             	pushl  0xc(%ebp)
  801480:	6a 3f                	push   $0x3f
  801482:	ff 55 08             	call   *0x8(%ebp)
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	eb 0d                	jmp    801497 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	ff 75 0c             	pushl  0xc(%ebp)
  801490:	52                   	push   %edx
  801491:	ff 55 08             	call   *0x8(%ebp)
  801494:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801497:	83 eb 01             	sub    $0x1,%ebx
  80149a:	eb 1a                	jmp    8014b6 <vprintfmt+0x23f>
  80149c:	89 75 08             	mov    %esi,0x8(%ebp)
  80149f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a8:	eb 0c                	jmp    8014b6 <vprintfmt+0x23f>
  8014aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b6:	83 c7 01             	add    $0x1,%edi
  8014b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014bd:	0f be d0             	movsbl %al,%edx
  8014c0:	85 d2                	test   %edx,%edx
  8014c2:	74 23                	je     8014e7 <vprintfmt+0x270>
  8014c4:	85 f6                	test   %esi,%esi
  8014c6:	78 a1                	js     801469 <vprintfmt+0x1f2>
  8014c8:	83 ee 01             	sub    $0x1,%esi
  8014cb:	79 9c                	jns    801469 <vprintfmt+0x1f2>
  8014cd:	89 df                	mov    %ebx,%edi
  8014cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d5:	eb 18                	jmp    8014ef <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	53                   	push   %ebx
  8014db:	6a 20                	push   $0x20
  8014dd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014df:	83 ef 01             	sub    $0x1,%edi
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	eb 08                	jmp    8014ef <vprintfmt+0x278>
  8014e7:	89 df                	mov    %ebx,%edi
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ef:	85 ff                	test   %edi,%edi
  8014f1:	7f e4                	jg     8014d7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f6:	e9 a2 fd ff ff       	jmp    80129d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fb:	83 fa 01             	cmp    $0x1,%edx
  8014fe:	7e 16                	jle    801516 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 50 08             	lea    0x8(%eax),%edx
  801506:	89 55 14             	mov    %edx,0x14(%ebp)
  801509:	8b 50 04             	mov    0x4(%eax),%edx
  80150c:	8b 00                	mov    (%eax),%eax
  80150e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801511:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801514:	eb 32                	jmp    801548 <vprintfmt+0x2d1>
	else if (lflag)
  801516:	85 d2                	test   %edx,%edx
  801518:	74 18                	je     801532 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8d 50 04             	lea    0x4(%eax),%edx
  801520:	89 55 14             	mov    %edx,0x14(%ebp)
  801523:	8b 00                	mov    (%eax),%eax
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	89 c1                	mov    %eax,%ecx
  80152a:	c1 f9 1f             	sar    $0x1f,%ecx
  80152d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801530:	eb 16                	jmp    801548 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801532:	8b 45 14             	mov    0x14(%ebp),%eax
  801535:	8d 50 04             	lea    0x4(%eax),%edx
  801538:	89 55 14             	mov    %edx,0x14(%ebp)
  80153b:	8b 00                	mov    (%eax),%eax
  80153d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801540:	89 c1                	mov    %eax,%ecx
  801542:	c1 f9 1f             	sar    $0x1f,%ecx
  801545:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801548:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80154e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801553:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801557:	79 74                	jns    8015cd <vprintfmt+0x356>
				putch('-', putdat);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	53                   	push   %ebx
  80155d:	6a 2d                	push   $0x2d
  80155f:	ff d6                	call   *%esi
				num = -(long long) num;
  801561:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801564:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801567:	f7 d8                	neg    %eax
  801569:	83 d2 00             	adc    $0x0,%edx
  80156c:	f7 da                	neg    %edx
  80156e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801571:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801576:	eb 55                	jmp    8015cd <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801578:	8d 45 14             	lea    0x14(%ebp),%eax
  80157b:	e8 83 fc ff ff       	call   801203 <getuint>
			base = 10;
  801580:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801585:	eb 46                	jmp    8015cd <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801587:	8d 45 14             	lea    0x14(%ebp),%eax
  80158a:	e8 74 fc ff ff       	call   801203 <getuint>
                        base = 8;
  80158f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801594:	eb 37                	jmp    8015cd <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	53                   	push   %ebx
  80159a:	6a 30                	push   $0x30
  80159c:	ff d6                	call   *%esi
			putch('x', putdat);
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	6a 78                	push   $0x78
  8015a4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a9:	8d 50 04             	lea    0x4(%eax),%edx
  8015ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015af:	8b 00                	mov    (%eax),%eax
  8015b1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015be:	eb 0d                	jmp    8015cd <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c3:	e8 3b fc ff ff       	call   801203 <getuint>
			base = 16;
  8015c8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015cd:	83 ec 0c             	sub    $0xc,%esp
  8015d0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d4:	57                   	push   %edi
  8015d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d8:	51                   	push   %ecx
  8015d9:	52                   	push   %edx
  8015da:	50                   	push   %eax
  8015db:	89 da                	mov    %ebx,%edx
  8015dd:	89 f0                	mov    %esi,%eax
  8015df:	e8 70 fb ff ff       	call   801154 <printnum>
			break;
  8015e4:	83 c4 20             	add    $0x20,%esp
  8015e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ea:	e9 ae fc ff ff       	jmp    80129d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	51                   	push   %ecx
  8015f4:	ff d6                	call   *%esi
			break;
  8015f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015fc:	e9 9c fc ff ff       	jmp    80129d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	53                   	push   %ebx
  801605:	6a 25                	push   $0x25
  801607:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 03                	jmp    801611 <vprintfmt+0x39a>
  80160e:	83 ef 01             	sub    $0x1,%edi
  801611:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801615:	75 f7                	jne    80160e <vprintfmt+0x397>
  801617:	e9 81 fc ff ff       	jmp    80129d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80161c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 18             	sub    $0x18,%esp
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801633:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801637:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80163a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801641:	85 c0                	test   %eax,%eax
  801643:	74 26                	je     80166b <vsnprintf+0x47>
  801645:	85 d2                	test   %edx,%edx
  801647:	7e 22                	jle    80166b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801649:	ff 75 14             	pushl  0x14(%ebp)
  80164c:	ff 75 10             	pushl  0x10(%ebp)
  80164f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	68 3d 12 80 00       	push   $0x80123d
  801658:	e8 1a fc ff ff       	call   801277 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80165d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801660:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 05                	jmp    801670 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80166b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801678:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167b:	50                   	push   %eax
  80167c:	ff 75 10             	pushl  0x10(%ebp)
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 9a ff ff ff       	call   801624 <vsnprintf>
	va_end(ap);

	return rc;
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801692:	b8 00 00 00 00       	mov    $0x0,%eax
  801697:	eb 03                	jmp    80169c <strlen+0x10>
		n++;
  801699:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80169c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a0:	75 f7                	jne    801699 <strlen+0xd>
		n++;
	return n;
}
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	eb 03                	jmp    8016b7 <strnlen+0x13>
		n++;
  8016b4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b7:	39 c2                	cmp    %eax,%edx
  8016b9:	74 08                	je     8016c3 <strnlen+0x1f>
  8016bb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016bf:	75 f3                	jne    8016b4 <strnlen+0x10>
  8016c1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	83 c2 01             	add    $0x1,%edx
  8016d4:	83 c1 01             	add    $0x1,%ecx
  8016d7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016de:	84 db                	test   %bl,%bl
  8016e0:	75 ef                	jne    8016d1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e2:	5b                   	pop    %ebx
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ec:	53                   	push   %ebx
  8016ed:	e8 9a ff ff ff       	call   80168c <strlen>
  8016f2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	01 d8                	add    %ebx,%eax
  8016fa:	50                   	push   %eax
  8016fb:	e8 c5 ff ff ff       	call   8016c5 <strcpy>
	return dst;
}
  801700:	89 d8                	mov    %ebx,%eax
  801702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	8b 75 08             	mov    0x8(%ebp),%esi
  80170f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801712:	89 f3                	mov    %esi,%ebx
  801714:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801717:	89 f2                	mov    %esi,%edx
  801719:	eb 0f                	jmp    80172a <strncpy+0x23>
		*dst++ = *src;
  80171b:	83 c2 01             	add    $0x1,%edx
  80171e:	0f b6 01             	movzbl (%ecx),%eax
  801721:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801724:	80 39 01             	cmpb   $0x1,(%ecx)
  801727:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172a:	39 da                	cmp    %ebx,%edx
  80172c:	75 ed                	jne    80171b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80172e:	89 f0                	mov    %esi,%eax
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	8b 75 08             	mov    0x8(%ebp),%esi
  80173c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173f:	8b 55 10             	mov    0x10(%ebp),%edx
  801742:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801744:	85 d2                	test   %edx,%edx
  801746:	74 21                	je     801769 <strlcpy+0x35>
  801748:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80174c:	89 f2                	mov    %esi,%edx
  80174e:	eb 09                	jmp    801759 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801750:	83 c2 01             	add    $0x1,%edx
  801753:	83 c1 01             	add    $0x1,%ecx
  801756:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801759:	39 c2                	cmp    %eax,%edx
  80175b:	74 09                	je     801766 <strlcpy+0x32>
  80175d:	0f b6 19             	movzbl (%ecx),%ebx
  801760:	84 db                	test   %bl,%bl
  801762:	75 ec                	jne    801750 <strlcpy+0x1c>
  801764:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801766:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801769:	29 f0                	sub    %esi,%eax
}
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801775:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801778:	eb 06                	jmp    801780 <strcmp+0x11>
		p++, q++;
  80177a:	83 c1 01             	add    $0x1,%ecx
  80177d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801780:	0f b6 01             	movzbl (%ecx),%eax
  801783:	84 c0                	test   %al,%al
  801785:	74 04                	je     80178b <strcmp+0x1c>
  801787:	3a 02                	cmp    (%edx),%al
  801789:	74 ef                	je     80177a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80178b:	0f b6 c0             	movzbl %al,%eax
  80178e:	0f b6 12             	movzbl (%edx),%edx
  801791:	29 d0                	sub    %edx,%eax
}
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a4:	eb 06                	jmp    8017ac <strncmp+0x17>
		n--, p++, q++;
  8017a6:	83 c0 01             	add    $0x1,%eax
  8017a9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ac:	39 d8                	cmp    %ebx,%eax
  8017ae:	74 15                	je     8017c5 <strncmp+0x30>
  8017b0:	0f b6 08             	movzbl (%eax),%ecx
  8017b3:	84 c9                	test   %cl,%cl
  8017b5:	74 04                	je     8017bb <strncmp+0x26>
  8017b7:	3a 0a                	cmp    (%edx),%cl
  8017b9:	74 eb                	je     8017a6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017bb:	0f b6 00             	movzbl (%eax),%eax
  8017be:	0f b6 12             	movzbl (%edx),%edx
  8017c1:	29 d0                	sub    %edx,%eax
  8017c3:	eb 05                	jmp    8017ca <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ca:	5b                   	pop    %ebx
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d7:	eb 07                	jmp    8017e0 <strchr+0x13>
		if (*s == c)
  8017d9:	38 ca                	cmp    %cl,%dl
  8017db:	74 0f                	je     8017ec <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017dd:	83 c0 01             	add    $0x1,%eax
  8017e0:	0f b6 10             	movzbl (%eax),%edx
  8017e3:	84 d2                	test   %dl,%dl
  8017e5:	75 f2                	jne    8017d9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f8:	eb 03                	jmp    8017fd <strfind+0xf>
  8017fa:	83 c0 01             	add    $0x1,%eax
  8017fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801800:	38 ca                	cmp    %cl,%dl
  801802:	74 04                	je     801808 <strfind+0x1a>
  801804:	84 d2                	test   %dl,%dl
  801806:	75 f2                	jne    8017fa <strfind+0xc>
			break;
	return (char *) s;
}
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	57                   	push   %edi
  80180e:	56                   	push   %esi
  80180f:	53                   	push   %ebx
  801810:	8b 7d 08             	mov    0x8(%ebp),%edi
  801813:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801816:	85 c9                	test   %ecx,%ecx
  801818:	74 36                	je     801850 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80181a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801820:	75 28                	jne    80184a <memset+0x40>
  801822:	f6 c1 03             	test   $0x3,%cl
  801825:	75 23                	jne    80184a <memset+0x40>
		c &= 0xFF;
  801827:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182b:	89 d3                	mov    %edx,%ebx
  80182d:	c1 e3 08             	shl    $0x8,%ebx
  801830:	89 d6                	mov    %edx,%esi
  801832:	c1 e6 18             	shl    $0x18,%esi
  801835:	89 d0                	mov    %edx,%eax
  801837:	c1 e0 10             	shl    $0x10,%eax
  80183a:	09 f0                	or     %esi,%eax
  80183c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80183e:	89 d8                	mov    %ebx,%eax
  801840:	09 d0                	or     %edx,%eax
  801842:	c1 e9 02             	shr    $0x2,%ecx
  801845:	fc                   	cld    
  801846:	f3 ab                	rep stos %eax,%es:(%edi)
  801848:	eb 06                	jmp    801850 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	fc                   	cld    
  80184e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801850:	89 f8                	mov    %edi,%eax
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	57                   	push   %edi
  80185b:	56                   	push   %esi
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801865:	39 c6                	cmp    %eax,%esi
  801867:	73 35                	jae    80189e <memmove+0x47>
  801869:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186c:	39 d0                	cmp    %edx,%eax
  80186e:	73 2e                	jae    80189e <memmove+0x47>
		s += n;
		d += n;
  801870:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801873:	89 d6                	mov    %edx,%esi
  801875:	09 fe                	or     %edi,%esi
  801877:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80187d:	75 13                	jne    801892 <memmove+0x3b>
  80187f:	f6 c1 03             	test   $0x3,%cl
  801882:	75 0e                	jne    801892 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801884:	83 ef 04             	sub    $0x4,%edi
  801887:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188a:	c1 e9 02             	shr    $0x2,%ecx
  80188d:	fd                   	std    
  80188e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801890:	eb 09                	jmp    80189b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801892:	83 ef 01             	sub    $0x1,%edi
  801895:	8d 72 ff             	lea    -0x1(%edx),%esi
  801898:	fd                   	std    
  801899:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189b:	fc                   	cld    
  80189c:	eb 1d                	jmp    8018bb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189e:	89 f2                	mov    %esi,%edx
  8018a0:	09 c2                	or     %eax,%edx
  8018a2:	f6 c2 03             	test   $0x3,%dl
  8018a5:	75 0f                	jne    8018b6 <memmove+0x5f>
  8018a7:	f6 c1 03             	test   $0x3,%cl
  8018aa:	75 0a                	jne    8018b6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ac:	c1 e9 02             	shr    $0x2,%ecx
  8018af:	89 c7                	mov    %eax,%edi
  8018b1:	fc                   	cld    
  8018b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b4:	eb 05                	jmp    8018bb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b6:	89 c7                	mov    %eax,%edi
  8018b8:	fc                   	cld    
  8018b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c2:	ff 75 10             	pushl  0x10(%ebp)
  8018c5:	ff 75 0c             	pushl  0xc(%ebp)
  8018c8:	ff 75 08             	pushl  0x8(%ebp)
  8018cb:	e8 87 ff ff ff       	call   801857 <memmove>
}
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dd:	89 c6                	mov    %eax,%esi
  8018df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e2:	eb 1a                	jmp    8018fe <memcmp+0x2c>
		if (*s1 != *s2)
  8018e4:	0f b6 08             	movzbl (%eax),%ecx
  8018e7:	0f b6 1a             	movzbl (%edx),%ebx
  8018ea:	38 d9                	cmp    %bl,%cl
  8018ec:	74 0a                	je     8018f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ee:	0f b6 c1             	movzbl %cl,%eax
  8018f1:	0f b6 db             	movzbl %bl,%ebx
  8018f4:	29 d8                	sub    %ebx,%eax
  8018f6:	eb 0f                	jmp    801907 <memcmp+0x35>
		s1++, s2++;
  8018f8:	83 c0 01             	add    $0x1,%eax
  8018fb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fe:	39 f0                	cmp    %esi,%eax
  801900:	75 e2                	jne    8018e4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801912:	89 c1                	mov    %eax,%ecx
  801914:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801917:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191b:	eb 0a                	jmp    801927 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191d:	0f b6 10             	movzbl (%eax),%edx
  801920:	39 da                	cmp    %ebx,%edx
  801922:	74 07                	je     80192b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801924:	83 c0 01             	add    $0x1,%eax
  801927:	39 c8                	cmp    %ecx,%eax
  801929:	72 f2                	jb     80191d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80192b:	5b                   	pop    %ebx
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801937:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193a:	eb 03                	jmp    80193f <strtol+0x11>
		s++;
  80193c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193f:	0f b6 01             	movzbl (%ecx),%eax
  801942:	3c 20                	cmp    $0x20,%al
  801944:	74 f6                	je     80193c <strtol+0xe>
  801946:	3c 09                	cmp    $0x9,%al
  801948:	74 f2                	je     80193c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80194a:	3c 2b                	cmp    $0x2b,%al
  80194c:	75 0a                	jne    801958 <strtol+0x2a>
		s++;
  80194e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801951:	bf 00 00 00 00       	mov    $0x0,%edi
  801956:	eb 11                	jmp    801969 <strtol+0x3b>
  801958:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80195d:	3c 2d                	cmp    $0x2d,%al
  80195f:	75 08                	jne    801969 <strtol+0x3b>
		s++, neg = 1;
  801961:	83 c1 01             	add    $0x1,%ecx
  801964:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801969:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196f:	75 15                	jne    801986 <strtol+0x58>
  801971:	80 39 30             	cmpb   $0x30,(%ecx)
  801974:	75 10                	jne    801986 <strtol+0x58>
  801976:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80197a:	75 7c                	jne    8019f8 <strtol+0xca>
		s += 2, base = 16;
  80197c:	83 c1 02             	add    $0x2,%ecx
  80197f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801984:	eb 16                	jmp    80199c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801986:	85 db                	test   %ebx,%ebx
  801988:	75 12                	jne    80199c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80198f:	80 39 30             	cmpb   $0x30,(%ecx)
  801992:	75 08                	jne    80199c <strtol+0x6e>
		s++, base = 8;
  801994:	83 c1 01             	add    $0x1,%ecx
  801997:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a4:	0f b6 11             	movzbl (%ecx),%edx
  8019a7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019aa:	89 f3                	mov    %esi,%ebx
  8019ac:	80 fb 09             	cmp    $0x9,%bl
  8019af:	77 08                	ja     8019b9 <strtol+0x8b>
			dig = *s - '0';
  8019b1:	0f be d2             	movsbl %dl,%edx
  8019b4:	83 ea 30             	sub    $0x30,%edx
  8019b7:	eb 22                	jmp    8019db <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019b9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019bc:	89 f3                	mov    %esi,%ebx
  8019be:	80 fb 19             	cmp    $0x19,%bl
  8019c1:	77 08                	ja     8019cb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019c3:	0f be d2             	movsbl %dl,%edx
  8019c6:	83 ea 57             	sub    $0x57,%edx
  8019c9:	eb 10                	jmp    8019db <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019cb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ce:	89 f3                	mov    %esi,%ebx
  8019d0:	80 fb 19             	cmp    $0x19,%bl
  8019d3:	77 16                	ja     8019eb <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019d5:	0f be d2             	movsbl %dl,%edx
  8019d8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019db:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019de:	7d 0b                	jge    8019eb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019e0:	83 c1 01             	add    $0x1,%ecx
  8019e3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e9:	eb b9                	jmp    8019a4 <strtol+0x76>

	if (endptr)
  8019eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ef:	74 0d                	je     8019fe <strtol+0xd0>
		*endptr = (char *) s;
  8019f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f4:	89 0e                	mov    %ecx,(%esi)
  8019f6:	eb 06                	jmp    8019fe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f8:	85 db                	test   %ebx,%ebx
  8019fa:	74 98                	je     801994 <strtol+0x66>
  8019fc:	eb 9e                	jmp    80199c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019fe:	89 c2                	mov    %eax,%edx
  801a00:	f7 da                	neg    %edx
  801a02:	85 ff                	test   %edi,%edi
  801a04:	0f 45 c2             	cmovne %edx,%eax
}
  801a07:	5b                   	pop    %ebx
  801a08:	5e                   	pop    %esi
  801a09:	5f                   	pop    %edi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	8b 75 08             	mov    0x8(%ebp),%esi
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a1a:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a1c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a21:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	50                   	push   %eax
  801a28:	e8 e6 e8 ff ff       	call   800313 <sys_ipc_recv>

	if (r < 0) {
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	85 c0                	test   %eax,%eax
  801a32:	79 16                	jns    801a4a <ipc_recv+0x3e>
		if (from_env_store)
  801a34:	85 f6                	test   %esi,%esi
  801a36:	74 06                	je     801a3e <ipc_recv+0x32>
			*from_env_store = 0;
  801a38:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a3e:	85 db                	test   %ebx,%ebx
  801a40:	74 2c                	je     801a6e <ipc_recv+0x62>
			*perm_store = 0;
  801a42:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a48:	eb 24                	jmp    801a6e <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a4a:	85 f6                	test   %esi,%esi
  801a4c:	74 0a                	je     801a58 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a53:	8b 40 74             	mov    0x74(%eax),%eax
  801a56:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a58:	85 db                	test   %ebx,%ebx
  801a5a:	74 0a                	je     801a66 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a61:	8b 40 78             	mov    0x78(%eax),%eax
  801a64:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	57                   	push   %edi
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a87:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a89:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a8e:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a91:	ff 75 14             	pushl  0x14(%ebp)
  801a94:	53                   	push   %ebx
  801a95:	56                   	push   %esi
  801a96:	57                   	push   %edi
  801a97:	e8 54 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa2:	75 07                	jne    801aab <ipc_send+0x36>
			sys_yield();
  801aa4:	e8 9b e6 ff ff       	call   800144 <sys_yield>
  801aa9:	eb e6                	jmp    801a91 <ipc_send+0x1c>
		} else if (r < 0) {
  801aab:	85 c0                	test   %eax,%eax
  801aad:	79 12                	jns    801ac1 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801aaf:	50                   	push   %eax
  801ab0:	68 40 22 80 00       	push   $0x802240
  801ab5:	6a 51                	push   $0x51
  801ab7:	68 4d 22 80 00       	push   $0x80224d
  801abc:	e8 a6 f5 ff ff       	call   801067 <_panic>
		}
	}
}
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801add:	8b 52 50             	mov    0x50(%edx),%edx
  801ae0:	39 ca                	cmp    %ecx,%edx
  801ae2:	75 0d                	jne    801af1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aec:	8b 40 48             	mov    0x48(%eax),%eax
  801aef:	eb 0f                	jmp    801b00 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af1:	83 c0 01             	add    $0x1,%eax
  801af4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af9:	75 d9                	jne    801ad4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b08:	89 d0                	mov    %edx,%eax
  801b0a:	c1 e8 16             	shr    $0x16,%eax
  801b0d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b19:	f6 c1 01             	test   $0x1,%cl
  801b1c:	74 1d                	je     801b3b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1e:	c1 ea 0c             	shr    $0xc,%edx
  801b21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b28:	f6 c2 01             	test   $0x1,%dl
  801b2b:	74 0e                	je     801b3b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2d:	c1 ea 0c             	shr    $0xc,%edx
  801b30:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b37:	ef 
  801b38:	0f b7 c0             	movzwl %ax,%eax
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

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
