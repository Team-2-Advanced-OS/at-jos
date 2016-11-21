
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 80 1e 80 00       	push   $0x801e80
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 83 1e 80 00       	push   $0x801e83
  80008f:	6a 01                	push   $0x1
  800091:	e8 8b 0a 00 00       	call   800b21 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 6f 0a 00 00       	call   800b21 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 9f 1f 80 00       	push   $0x801f9f
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 4e 0a 00 00       	call   800b21 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 07 08 00 00       	call   800936 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 8f 1e 80 00       	push   $0x801e8f
  800528:	6a 23                	push   $0x23
  80052a:	68 ac 1e 80 00       	push   $0x801eac
  80052f:	e8 4a 0f 00 00       	call   80147e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 8f 1e 80 00       	push   $0x801e8f
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 ac 1e 80 00       	push   $0x801eac
  8005b0:	e8 c9 0e 00 00       	call   80147e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 8f 1e 80 00       	push   $0x801e8f
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 ac 1e 80 00       	push   $0x801eac
  8005f2:	e8 87 0e 00 00       	call   80147e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 8f 1e 80 00       	push   $0x801e8f
  80062d:	6a 23                	push   $0x23
  80062f:	68 ac 1e 80 00       	push   $0x801eac
  800634:	e8 45 0e 00 00       	call   80147e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 8f 1e 80 00       	push   $0x801e8f
  80066f:	6a 23                	push   $0x23
  800671:	68 ac 1e 80 00       	push   $0x801eac
  800676:	e8 03 0e 00 00       	call   80147e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 8f 1e 80 00       	push   $0x801e8f
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 ac 1e 80 00       	push   $0x801eac
  8006b8:	e8 c1 0d 00 00       	call   80147e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 8f 1e 80 00       	push   $0x801e8f
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 ac 1e 80 00       	push   $0x801eac
  8006fa:	e8 7f 0d 00 00       	call   80147e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 8f 1e 80 00       	push   $0x801e8f
  800757:	6a 23                	push   $0x23
  800759:	68 ac 1e 80 00       	push   $0x801eac
  80075e:	e8 1b 0d 00 00       	call   80147e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	05 00 00 00 30       	add    $0x30000000,%eax
  800776:	c1 e8 0c             	shr    $0xc,%eax
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	05 00 00 00 30       	add    $0x30000000,%eax
  800786:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80078b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	c1 ea 16             	shr    $0x16,%edx
  8007a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a9:	f6 c2 01             	test   $0x1,%dl
  8007ac:	74 11                	je     8007bf <fd_alloc+0x2d>
  8007ae:	89 c2                	mov    %eax,%edx
  8007b0:	c1 ea 0c             	shr    $0xc,%edx
  8007b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007ba:	f6 c2 01             	test   $0x1,%dl
  8007bd:	75 09                	jne    8007c8 <fd_alloc+0x36>
			*fd_store = fd;
  8007bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 17                	jmp    8007df <fd_alloc+0x4d>
  8007c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007d2:	75 c9                	jne    80079d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007d4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e7:	83 f8 1f             	cmp    $0x1f,%eax
  8007ea:	77 36                	ja     800822 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007ec:	c1 e0 0c             	shl    $0xc,%eax
  8007ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	c1 ea 16             	shr    $0x16,%edx
  8007f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800800:	f6 c2 01             	test   $0x1,%dl
  800803:	74 24                	je     800829 <fd_lookup+0x48>
  800805:	89 c2                	mov    %eax,%edx
  800807:	c1 ea 0c             	shr    $0xc,%edx
  80080a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800811:	f6 c2 01             	test   $0x1,%dl
  800814:	74 1a                	je     800830 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 02                	mov    %eax,(%edx)
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 13                	jmp    800835 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb 0c                	jmp    800835 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb 05                	jmp    800835 <fd_lookup+0x54>
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	ba 38 1f 80 00       	mov    $0x801f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800845:	eb 13                	jmp    80085a <dev_lookup+0x23>
  800847:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80084a:	39 08                	cmp    %ecx,(%eax)
  80084c:	75 0c                	jne    80085a <dev_lookup+0x23>
			*dev = devtab[i];
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	89 01                	mov    %eax,(%ecx)
			return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 2e                	jmp    800888 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80085a:	8b 02                	mov    (%edx),%eax
  80085c:	85 c0                	test   %eax,%eax
  80085e:	75 e7                	jne    800847 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800860:	a1 04 40 80 00       	mov    0x804004,%eax
  800865:	8b 40 48             	mov    0x48(%eax),%eax
  800868:	83 ec 04             	sub    $0x4,%esp
  80086b:	51                   	push   %ecx
  80086c:	50                   	push   %eax
  80086d:	68 bc 1e 80 00       	push   $0x801ebc
  800872:	e8 e0 0c 00 00       	call   801557 <cprintf>
	*dev = 0;
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	83 ec 10             	sub    $0x10,%esp
  800892:	8b 75 08             	mov    0x8(%ebp),%esi
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800898:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a2:	c1 e8 0c             	shr    $0xc,%eax
  8008a5:	50                   	push   %eax
  8008a6:	e8 36 ff ff ff       	call   8007e1 <fd_lookup>
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 05                	js     8008b7 <fd_close+0x2d>
	    || fd != fd2)
  8008b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008b5:	74 0c                	je     8008c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008be:	0f 44 c2             	cmove  %edx,%eax
  8008c1:	eb 41                	jmp    800904 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	ff 36                	pushl  (%esi)
  8008cc:	e8 66 ff ff ff       	call   800837 <dev_lookup>
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 1a                	js     8008f4 <fd_close+0x6a>
		if (dev->dev_close)
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	74 0b                	je     8008f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008e9:	83 ec 0c             	sub    $0xc,%esp
  8008ec:	56                   	push   %esi
  8008ed:	ff d0                	call   *%eax
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	56                   	push   %esi
  8008f8:	6a 00                	push   $0x0
  8008fa:	e8 00 fd ff ff       	call   8005ff <sys_page_unmap>
	return r;
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	89 d8                	mov    %ebx,%eax
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800914:	50                   	push   %eax
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 c4 fe ff ff       	call   8007e1 <fd_lookup>
  80091d:	83 c4 08             	add    $0x8,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 10                	js     800934 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	6a 01                	push   $0x1
  800929:	ff 75 f4             	pushl  -0xc(%ebp)
  80092c:	e8 59 ff ff ff       	call   80088a <fd_close>
  800931:	83 c4 10             	add    $0x10,%esp
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <close_all>:

void
close_all(void)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80093d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	53                   	push   %ebx
  800946:	e8 c0 ff ff ff       	call   80090b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80094b:	83 c3 01             	add    $0x1,%ebx
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	83 fb 20             	cmp    $0x20,%ebx
  800954:	75 ec                	jne    800942 <close_all+0xc>
		close(i);
}
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	83 ec 2c             	sub    $0x2c,%esp
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800967:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80096a:	50                   	push   %eax
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 6e fe ff ff       	call   8007e1 <fd_lookup>
  800973:	83 c4 08             	add    $0x8,%esp
  800976:	85 c0                	test   %eax,%eax
  800978:	0f 88 c1 00 00 00    	js     800a3f <dup+0xe4>
		return r;
	close(newfdnum);
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	56                   	push   %esi
  800982:	e8 84 ff ff ff       	call   80090b <close>

	newfd = INDEX2FD(newfdnum);
  800987:	89 f3                	mov    %esi,%ebx
  800989:	c1 e3 0c             	shl    $0xc,%ebx
  80098c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800992:	83 c4 04             	add    $0x4,%esp
  800995:	ff 75 e4             	pushl  -0x1c(%ebp)
  800998:	e8 de fd ff ff       	call   80077b <fd2data>
  80099d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80099f:	89 1c 24             	mov    %ebx,(%esp)
  8009a2:	e8 d4 fd ff ff       	call   80077b <fd2data>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	c1 e8 16             	shr    $0x16,%eax
  8009b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b9:	a8 01                	test   $0x1,%al
  8009bb:	74 37                	je     8009f4 <dup+0x99>
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	c1 e8 0c             	shr    $0xc,%eax
  8009c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009c9:	f6 c2 01             	test   $0x1,%dl
  8009cc:	74 26                	je     8009f4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009d5:	83 ec 0c             	sub    $0xc,%esp
  8009d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8009dd:	50                   	push   %eax
  8009de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009e1:	6a 00                	push   $0x0
  8009e3:	57                   	push   %edi
  8009e4:	6a 00                	push   $0x0
  8009e6:	e8 d2 fb ff ff       	call   8005bd <sys_page_map>
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	83 c4 20             	add    $0x20,%esp
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 2e                	js     800a22 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e8 0c             	shr    $0xc,%eax
  8009fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a03:	83 ec 0c             	sub    $0xc,%esp
  800a06:	25 07 0e 00 00       	and    $0xe07,%eax
  800a0b:	50                   	push   %eax
  800a0c:	53                   	push   %ebx
  800a0d:	6a 00                	push   $0x0
  800a0f:	52                   	push   %edx
  800a10:	6a 00                	push   $0x0
  800a12:	e8 a6 fb ff ff       	call   8005bd <sys_page_map>
  800a17:	89 c7                	mov    %eax,%edi
  800a19:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a1c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a1e:	85 ff                	test   %edi,%edi
  800a20:	79 1d                	jns    800a3f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	53                   	push   %ebx
  800a26:	6a 00                	push   $0x0
  800a28:	e8 d2 fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a2d:	83 c4 08             	add    $0x8,%esp
  800a30:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a33:	6a 00                	push   $0x0
  800a35:	e8 c5 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	89 f8                	mov    %edi,%eax
}
  800a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	83 ec 14             	sub    $0x14,%esp
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a54:	50                   	push   %eax
  800a55:	53                   	push   %ebx
  800a56:	e8 86 fd ff ff       	call   8007e1 <fd_lookup>
  800a5b:	83 c4 08             	add    $0x8,%esp
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 6d                	js     800ad1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6a:	50                   	push   %eax
  800a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6e:	ff 30                	pushl  (%eax)
  800a70:	e8 c2 fd ff ff       	call   800837 <dev_lookup>
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	78 4c                	js     800ac8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a7f:	8b 42 08             	mov    0x8(%edx),%eax
  800a82:	83 e0 03             	and    $0x3,%eax
  800a85:	83 f8 01             	cmp    $0x1,%eax
  800a88:	75 21                	jne    800aab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a8f:	8b 40 48             	mov    0x48(%eax),%eax
  800a92:	83 ec 04             	sub    $0x4,%esp
  800a95:	53                   	push   %ebx
  800a96:	50                   	push   %eax
  800a97:	68 fd 1e 80 00       	push   $0x801efd
  800a9c:	e8 b6 0a 00 00       	call   801557 <cprintf>
		return -E_INVAL;
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aa9:	eb 26                	jmp    800ad1 <read+0x8a>
	}
	if (!dev->dev_read)
  800aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aae:	8b 40 08             	mov    0x8(%eax),%eax
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 17                	je     800acc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	ff 75 10             	pushl  0x10(%ebp)
  800abb:	ff 75 0c             	pushl  0xc(%ebp)
  800abe:	52                   	push   %edx
  800abf:	ff d0                	call   *%eax
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 09                	jmp    800ad1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	eb 05                	jmp    800ad1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800acc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aec:	eb 21                	jmp    800b0f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aee:	83 ec 04             	sub    $0x4,%esp
  800af1:	89 f0                	mov    %esi,%eax
  800af3:	29 d8                	sub    %ebx,%eax
  800af5:	50                   	push   %eax
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	03 45 0c             	add    0xc(%ebp),%eax
  800afb:	50                   	push   %eax
  800afc:	57                   	push   %edi
  800afd:	e8 45 ff ff ff       	call   800a47 <read>
		if (m < 0)
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 10                	js     800b19 <readn+0x41>
			return m;
		if (m == 0)
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	74 0a                	je     800b17 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b0d:	01 c3                	add    %eax,%ebx
  800b0f:	39 f3                	cmp    %esi,%ebx
  800b11:	72 db                	jb     800aee <readn+0x16>
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	eb 02                	jmp    800b19 <readn+0x41>
  800b17:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 14             	sub    $0x14,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b2e:	50                   	push   %eax
  800b2f:	53                   	push   %ebx
  800b30:	e8 ac fc ff ff       	call   8007e1 <fd_lookup>
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 68                	js     800ba6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b44:	50                   	push   %eax
  800b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b48:	ff 30                	pushl  (%eax)
  800b4a:	e8 e8 fc ff ff       	call   800837 <dev_lookup>
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 47                	js     800b9d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b59:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b5d:	75 21                	jne    800b80 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  800b64:	8b 40 48             	mov    0x48(%eax),%eax
  800b67:	83 ec 04             	sub    $0x4,%esp
  800b6a:	53                   	push   %ebx
  800b6b:	50                   	push   %eax
  800b6c:	68 19 1f 80 00       	push   $0x801f19
  800b71:	e8 e1 09 00 00       	call   801557 <cprintf>
		return -E_INVAL;
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b7e:	eb 26                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b83:	8b 52 0c             	mov    0xc(%edx),%edx
  800b86:	85 d2                	test   %edx,%edx
  800b88:	74 17                	je     800ba1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b8a:	83 ec 04             	sub    $0x4,%esp
  800b8d:	ff 75 10             	pushl  0x10(%ebp)
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	50                   	push   %eax
  800b94:	ff d2                	call   *%edx
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb 09                	jmp    800ba6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 05                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ba1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <seek>:

int
seek(int fdnum, off_t offset)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bb3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bb6:	50                   	push   %eax
  800bb7:	ff 75 08             	pushl  0x8(%ebp)
  800bba:	e8 22 fc ff ff       	call   8007e1 <fd_lookup>
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	78 0e                	js     800bd4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 14             	sub    $0x14,%esp
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800be0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800be3:	50                   	push   %eax
  800be4:	53                   	push   %ebx
  800be5:	e8 f7 fb ff ff       	call   8007e1 <fd_lookup>
  800bea:	83 c4 08             	add    $0x8,%esp
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	78 65                	js     800c58 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bf3:	83 ec 08             	sub    $0x8,%esp
  800bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf9:	50                   	push   %eax
  800bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfd:	ff 30                	pushl  (%eax)
  800bff:	e8 33 fc ff ff       	call   800837 <dev_lookup>
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	85 c0                	test   %eax,%eax
  800c09:	78 44                	js     800c4f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c12:	75 21                	jne    800c35 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c14:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c19:	8b 40 48             	mov    0x48(%eax),%eax
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	53                   	push   %ebx
  800c20:	50                   	push   %eax
  800c21:	68 dc 1e 80 00       	push   $0x801edc
  800c26:	e8 2c 09 00 00       	call   801557 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c33:	eb 23                	jmp    800c58 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c38:	8b 52 18             	mov    0x18(%edx),%edx
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 14                	je     800c53 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	50                   	push   %eax
  800c46:	ff d2                	call   *%edx
  800c48:	89 c2                	mov    %eax,%edx
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb 09                	jmp    800c58 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	eb 05                	jmp    800c58 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c58:	89 d0                	mov    %edx,%eax
  800c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	53                   	push   %ebx
  800c63:	83 ec 14             	sub    $0x14,%esp
  800c66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c6c:	50                   	push   %eax
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	e8 6c fb ff ff       	call   8007e1 <fd_lookup>
  800c75:	83 c4 08             	add    $0x8,%esp
  800c78:	89 c2                	mov    %eax,%edx
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 58                	js     800cd6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c84:	50                   	push   %eax
  800c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c88:	ff 30                	pushl  (%eax)
  800c8a:	e8 a8 fb ff ff       	call   800837 <dev_lookup>
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	85 c0                	test   %eax,%eax
  800c94:	78 37                	js     800ccd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c9d:	74 32                	je     800cd1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c9f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ca2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ca9:	00 00 00 
	stat->st_isdir = 0;
  800cac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cb3:	00 00 00 
	stat->st_dev = dev;
  800cb6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cbc:	83 ec 08             	sub    $0x8,%esp
  800cbf:	53                   	push   %ebx
  800cc0:	ff 75 f0             	pushl  -0x10(%ebp)
  800cc3:	ff 50 14             	call   *0x14(%eax)
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	eb 09                	jmp    800cd6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	eb 05                	jmp    800cd6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cd6:	89 d0                	mov    %edx,%eax
  800cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	6a 00                	push   $0x0
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	e8 0c 02 00 00       	call   800efb <open>
  800cef:	89 c3                	mov    %eax,%ebx
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 1b                	js     800d13 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	50                   	push   %eax
  800cff:	e8 5b ff ff ff       	call   800c5f <fstat>
  800d04:	89 c6                	mov    %eax,%esi
	close(fd);
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	e8 fd fb ff ff       	call   80090b <close>
	return r;
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	89 f0                	mov    %esi,%eax
}
  800d13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	89 c6                	mov    %eax,%esi
  800d21:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d23:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d2a:	75 12                	jne    800d3e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	6a 01                	push   $0x1
  800d31:	e8 2a 0e 00 00       	call   801b60 <ipc_find_env>
  800d36:	a3 00 40 80 00       	mov    %eax,0x804000
  800d3b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d3e:	6a 07                	push   $0x7
  800d40:	68 00 50 80 00       	push   $0x805000
  800d45:	56                   	push   %esi
  800d46:	ff 35 00 40 80 00    	pushl  0x804000
  800d4c:	e8 bb 0d 00 00       	call   801b0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d51:	83 c4 0c             	add    $0xc,%esp
  800d54:	6a 00                	push   $0x0
  800d56:	53                   	push   %ebx
  800d57:	6a 00                	push   $0x0
  800d59:	e8 45 0d 00 00       	call   801aa3 <ipc_recv>
}
  800d5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d71:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 02 00 00 00       	mov    $0x2,%eax
  800d88:	e8 8d ff ff ff       	call   800d1a <fsipc>
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 06 00 00 00       	mov    $0x6,%eax
  800daa:	e8 6b ff ff ff       	call   800d1a <fsipc>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd0:	e8 45 ff ff ff       	call   800d1a <fsipc>
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	78 2c                	js     800e05 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd9:	83 ec 08             	sub    $0x8,%esp
  800ddc:	68 00 50 80 00       	push   $0x805000
  800de1:	53                   	push   %ebx
  800de2:	e8 90 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800de7:	a1 80 50 80 00       	mov    0x805080,%eax
  800dec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800df2:	a1 84 50 80 00       	mov    0x805084,%eax
  800df7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 52 0c             	mov    0xc(%edx),%edx
  800e1a:	89 15 00 50 80 00    	mov    %edx,0x805000
  800e20:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e25:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800e2a:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800e2d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800e33:	53                   	push   %ebx
  800e34:	ff 75 0c             	pushl  0xc(%ebp)
  800e37:	68 08 50 80 00       	push   $0x805008
  800e3c:	e8 c8 f4 ff ff       	call   800309 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4b:	e8 ca fe ff ff       	call   800d1a <fsipc>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 1d                	js     800e74 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800e57:	39 d8                	cmp    %ebx,%eax
  800e59:	76 19                	jbe    800e74 <devfile_write+0x6a>
  800e5b:	68 48 1f 80 00       	push   $0x801f48
  800e60:	68 54 1f 80 00       	push   $0x801f54
  800e65:	68 a5 00 00 00       	push   $0xa5
  800e6a:	68 69 1f 80 00       	push   $0x801f69
  800e6f:	e8 0a 06 00 00       	call   80147e <_panic>
	return r;
}
  800e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	8b 40 0c             	mov    0xc(%eax),%eax
  800e87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9c:	e8 79 fe ff ff       	call   800d1a <fsipc>
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	78 4b                	js     800ef2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ea7:	39 c6                	cmp    %eax,%esi
  800ea9:	73 16                	jae    800ec1 <devfile_read+0x48>
  800eab:	68 74 1f 80 00       	push   $0x801f74
  800eb0:	68 54 1f 80 00       	push   $0x801f54
  800eb5:	6a 7c                	push   $0x7c
  800eb7:	68 69 1f 80 00       	push   $0x801f69
  800ebc:	e8 bd 05 00 00       	call   80147e <_panic>
	assert(r <= PGSIZE);
  800ec1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ec6:	7e 16                	jle    800ede <devfile_read+0x65>
  800ec8:	68 7b 1f 80 00       	push   $0x801f7b
  800ecd:	68 54 1f 80 00       	push   $0x801f54
  800ed2:	6a 7d                	push   $0x7d
  800ed4:	68 69 1f 80 00       	push   $0x801f69
  800ed9:	e8 a0 05 00 00       	call   80147e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	50                   	push   %eax
  800ee2:	68 00 50 80 00       	push   $0x805000
  800ee7:	ff 75 0c             	pushl  0xc(%ebp)
  800eea:	e8 1a f4 ff ff       	call   800309 <memmove>
	return r;
  800eef:	83 c4 10             	add    $0x10,%esp
}
  800ef2:	89 d8                	mov    %ebx,%eax
  800ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	83 ec 20             	sub    $0x20,%esp
  800f02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f05:	53                   	push   %ebx
  800f06:	e8 33 f2 ff ff       	call   80013e <strlen>
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f13:	7f 67                	jg     800f7c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	e8 71 f8 ff ff       	call   800792 <fd_alloc>
  800f21:	83 c4 10             	add    $0x10,%esp
		return r;
  800f24:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	78 57                	js     800f81 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	53                   	push   %ebx
  800f2e:	68 00 50 80 00       	push   $0x805000
  800f33:	e8 3f f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	e8 cd fd ff ff       	call   800d1a <fsipc>
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 14                	jns    800f6a <open+0x6f>
		fd_close(fd, 0);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	6a 00                	push   $0x0
  800f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5e:	e8 27 f9 ff ff       	call   80088a <fd_close>
		return r;
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	89 da                	mov    %ebx,%edx
  800f68:	eb 17                	jmp    800f81 <open+0x86>
	}

	return fd2num(fd);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f70:	e8 f6 f7 ff ff       	call   80076b <fd2num>
  800f75:	89 c2                	mov    %eax,%edx
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	eb 05                	jmp    800f81 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f7c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 08 00 00 00       	mov    $0x8,%eax
  800f98:	e8 7d fd ff ff       	call   800d1a <fsipc>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	ff 75 08             	pushl  0x8(%ebp)
  800fad:	e8 c9 f7 ff ff       	call   80077b <fd2data>
  800fb2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	68 87 1f 80 00       	push   $0x801f87
  800fbc:	53                   	push   %ebx
  800fbd:	e8 b5 f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fc2:	8b 46 04             	mov    0x4(%esi),%eax
  800fc5:	2b 06                	sub    (%esi),%eax
  800fc7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fcd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fd4:	00 00 00 
	stat->st_dev = &devpipe;
  800fd7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fde:	30 80 00 
	return 0;
}
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ff7:	53                   	push   %ebx
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 00 f6 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fff:	89 1c 24             	mov    %ebx,(%esp)
  801002:	e8 74 f7 ff ff       	call   80077b <fd2data>
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	50                   	push   %eax
  80100b:	6a 00                	push   $0x0
  80100d:	e8 ed f5 ff ff       	call   8005ff <sys_page_unmap>
}
  801012:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 1c             	sub    $0x1c,%esp
  801020:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801023:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801025:	a1 04 40 80 00       	mov    0x804004,%eax
  80102a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	ff 75 e0             	pushl  -0x20(%ebp)
  801033:	e8 61 0b 00 00       	call   801b99 <pageref>
  801038:	89 c3                	mov    %eax,%ebx
  80103a:	89 3c 24             	mov    %edi,(%esp)
  80103d:	e8 57 0b 00 00       	call   801b99 <pageref>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	39 c3                	cmp    %eax,%ebx
  801047:	0f 94 c1             	sete   %cl
  80104a:	0f b6 c9             	movzbl %cl,%ecx
  80104d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801050:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801056:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801059:	39 ce                	cmp    %ecx,%esi
  80105b:	74 1b                	je     801078 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80105d:	39 c3                	cmp    %eax,%ebx
  80105f:	75 c4                	jne    801025 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801061:	8b 42 58             	mov    0x58(%edx),%eax
  801064:	ff 75 e4             	pushl  -0x1c(%ebp)
  801067:	50                   	push   %eax
  801068:	56                   	push   %esi
  801069:	68 8e 1f 80 00       	push   $0x801f8e
  80106e:	e8 e4 04 00 00       	call   801557 <cprintf>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	eb ad                	jmp    801025 <_pipeisclosed+0xe>
	}
}
  801078:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 28             	sub    $0x28,%esp
  80108c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80108f:	56                   	push   %esi
  801090:	e8 e6 f6 ff ff       	call   80077b <fd2data>
  801095:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	bf 00 00 00 00       	mov    $0x0,%edi
  80109f:	eb 4b                	jmp    8010ec <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010a1:	89 da                	mov    %ebx,%edx
  8010a3:	89 f0                	mov    %esi,%eax
  8010a5:	e8 6d ff ff ff       	call   801017 <_pipeisclosed>
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	75 48                	jne    8010f6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010ae:	e8 a8 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8010b6:	8b 0b                	mov    (%ebx),%ecx
  8010b8:	8d 51 20             	lea    0x20(%ecx),%edx
  8010bb:	39 d0                	cmp    %edx,%eax
  8010bd:	73 e2                	jae    8010a1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010c6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 fa 1f             	sar    $0x1f,%edx
  8010ce:	89 d1                	mov    %edx,%ecx
  8010d0:	c1 e9 1b             	shr    $0x1b,%ecx
  8010d3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010d6:	83 e2 1f             	and    $0x1f,%edx
  8010d9:	29 ca                	sub    %ecx,%edx
  8010db:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010e3:	83 c0 01             	add    $0x1,%eax
  8010e6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010e9:	83 c7 01             	add    $0x1,%edi
  8010ec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010ef:	75 c2                	jne    8010b3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f4:	eb 05                	jmp    8010fb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 18             	sub    $0x18,%esp
  80110c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80110f:	57                   	push   %edi
  801110:	e8 66 f6 ff ff       	call   80077b <fd2data>
  801115:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111f:	eb 3d                	jmp    80115e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801121:	85 db                	test   %ebx,%ebx
  801123:	74 04                	je     801129 <devpipe_read+0x26>
				return i;
  801125:	89 d8                	mov    %ebx,%eax
  801127:	eb 44                	jmp    80116d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801129:	89 f2                	mov    %esi,%edx
  80112b:	89 f8                	mov    %edi,%eax
  80112d:	e8 e5 fe ff ff       	call   801017 <_pipeisclosed>
  801132:	85 c0                	test   %eax,%eax
  801134:	75 32                	jne    801168 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801136:	e8 20 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80113b:	8b 06                	mov    (%esi),%eax
  80113d:	3b 46 04             	cmp    0x4(%esi),%eax
  801140:	74 df                	je     801121 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801142:	99                   	cltd   
  801143:	c1 ea 1b             	shr    $0x1b,%edx
  801146:	01 d0                	add    %edx,%eax
  801148:	83 e0 1f             	and    $0x1f,%eax
  80114b:	29 d0                	sub    %edx,%eax
  80114d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801155:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801158:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115b:	83 c3 01             	add    $0x1,%ebx
  80115e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801161:	75 d8                	jne    80113b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801163:	8b 45 10             	mov    0x10(%ebp),%eax
  801166:	eb 05                	jmp    80116d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	e8 0c f6 ff ff       	call   800792 <fd_alloc>
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	89 c2                	mov    %eax,%edx
  80118b:	85 c0                	test   %eax,%eax
  80118d:	0f 88 2c 01 00 00    	js     8012bf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	68 07 04 00 00       	push   $0x407
  80119b:	ff 75 f4             	pushl  -0xc(%ebp)
  80119e:	6a 00                	push   $0x0
  8011a0:	e8 d5 f3 ff ff       	call   80057a <sys_page_alloc>
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	0f 88 0d 01 00 00    	js     8012bf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011b2:	83 ec 0c             	sub    $0xc,%esp
  8011b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	e8 d4 f5 ff ff       	call   800792 <fd_alloc>
  8011be:	89 c3                	mov    %eax,%ebx
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	0f 88 e2 00 00 00    	js     8012ad <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	68 07 04 00 00       	push   $0x407
  8011d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 9d f3 ff ff       	call   80057a <sys_page_alloc>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	0f 88 c3 00 00 00    	js     8012ad <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 86 f5 ff ff       	call   80077b <fd2data>
  8011f5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f7:	83 c4 0c             	add    $0xc,%esp
  8011fa:	68 07 04 00 00       	push   $0x407
  8011ff:	50                   	push   %eax
  801200:	6a 00                	push   $0x0
  801202:	e8 73 f3 ff ff       	call   80057a <sys_page_alloc>
  801207:	89 c3                	mov    %eax,%ebx
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	0f 88 89 00 00 00    	js     80129d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	ff 75 f0             	pushl  -0x10(%ebp)
  80121a:	e8 5c f5 ff ff       	call   80077b <fd2data>
  80121f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801226:	50                   	push   %eax
  801227:	6a 00                	push   $0x0
  801229:	56                   	push   %esi
  80122a:	6a 00                	push   $0x0
  80122c:	e8 8c f3 ff ff       	call   8005bd <sys_page_map>
  801231:	89 c3                	mov    %eax,%ebx
  801233:	83 c4 20             	add    $0x20,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	78 55                	js     80128f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80123a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801243:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801248:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80124f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801255:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801258:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80125a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	ff 75 f4             	pushl  -0xc(%ebp)
  80126a:	e8 fc f4 ff ff       	call   80076b <fd2num>
  80126f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801272:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801274:	83 c4 04             	add    $0x4,%esp
  801277:	ff 75 f0             	pushl  -0x10(%ebp)
  80127a:	e8 ec f4 ff ff       	call   80076b <fd2num>
  80127f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801282:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	ba 00 00 00 00       	mov    $0x0,%edx
  80128d:	eb 30                	jmp    8012bf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	56                   	push   %esi
  801293:	6a 00                	push   $0x0
  801295:	e8 65 f3 ff ff       	call   8005ff <sys_page_unmap>
  80129a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 55 f3 ff ff       	call   8005ff <sys_page_unmap>
  8012aa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b3:	6a 00                	push   $0x0
  8012b5:	e8 45 f3 ff ff       	call   8005ff <sys_page_unmap>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012bf:	89 d0                	mov    %edx,%eax
  8012c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 07 f5 ff ff       	call   8007e1 <fd_lookup>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 18                	js     8012f9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e7:	e8 8f f4 ff ff       	call   80077b <fd2data>
	return _pipeisclosed(fd, p);
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f1:	e8 21 fd ff ff       	call   801017 <_pipeisclosed>
  8012f6:	83 c4 10             	add    $0x10,%esp
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80130b:	68 a6 1f 80 00       	push   $0x801fa6
  801310:	ff 75 0c             	pushl  0xc(%ebp)
  801313:	e8 5f ee ff ff       	call   800177 <strcpy>
	return 0;
}
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	57                   	push   %edi
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80132b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801330:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801336:	eb 2d                	jmp    801365 <devcons_write+0x46>
		m = n - tot;
  801338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80133d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801340:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801345:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	03 45 0c             	add    0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	57                   	push   %edi
  801351:	e8 b3 ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  801356:	83 c4 08             	add    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	57                   	push   %edi
  80135b:	e8 5e f1 ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801360:	01 de                	add    %ebx,%esi
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	89 f0                	mov    %esi,%eax
  801367:	3b 75 10             	cmp    0x10(%ebp),%esi
  80136a:	72 cc                	jb     801338 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80137f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801383:	74 2a                	je     8013af <devcons_read+0x3b>
  801385:	eb 05                	jmp    80138c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801387:	e8 cf f1 ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80138c:	e8 4b f1 ff ff       	call   8004dc <sys_cgetc>
  801391:	85 c0                	test   %eax,%eax
  801393:	74 f2                	je     801387 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801395:	85 c0                	test   %eax,%eax
  801397:	78 16                	js     8013af <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801399:	83 f8 04             	cmp    $0x4,%eax
  80139c:	74 0c                	je     8013aa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	88 02                	mov    %al,(%edx)
	return 1;
  8013a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a8:	eb 05                	jmp    8013af <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013bd:	6a 01                	push   $0x1
  8013bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	e8 f6 f0 ff ff       	call   8004be <sys_cputs>
}
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <getchar>:

int
getchar(void)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013d3:	6a 01                	push   $0x1
  8013d5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 67 f6 ff ff       	call   800a47 <read>
	if (r < 0)
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 0f                	js     8013f6 <getchar+0x29>
		return r;
	if (r < 1)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	7e 06                	jle    8013f1 <getchar+0x24>
		return -E_EOF;
	return c;
  8013eb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013ef:	eb 05                	jmp    8013f6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013f1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	e8 d7 f3 ff ff       	call   8007e1 <fd_lookup>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 11                	js     801422 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801411:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801414:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80141a:	39 10                	cmp    %edx,(%eax)
  80141c:	0f 94 c0             	sete   %al
  80141f:	0f b6 c0             	movzbl %al,%eax
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <opencons>:

int
opencons(void)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	e8 5f f3 ff ff       	call   800792 <fd_alloc>
  801433:	83 c4 10             	add    $0x10,%esp
		return r;
  801436:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 3e                	js     80147a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	68 07 04 00 00       	push   $0x407
  801444:	ff 75 f4             	pushl  -0xc(%ebp)
  801447:	6a 00                	push   $0x0
  801449:	e8 2c f1 ff ff       	call   80057a <sys_page_alloc>
  80144e:	83 c4 10             	add    $0x10,%esp
		return r;
  801451:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	78 23                	js     80147a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801457:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801460:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	50                   	push   %eax
  801470:	e8 f6 f2 ff ff       	call   80076b <fd2num>
  801475:	89 c2                	mov    %eax,%edx
  801477:	83 c4 10             	add    $0x10,%esp
}
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801483:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801486:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80148c:	e8 ab f0 ff ff       	call   80053c <sys_getenvid>
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	56                   	push   %esi
  80149b:	50                   	push   %eax
  80149c:	68 b4 1f 80 00       	push   $0x801fb4
  8014a1:	e8 b1 00 00 00       	call   801557 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014a6:	83 c4 18             	add    $0x18,%esp
  8014a9:	53                   	push   %ebx
  8014aa:	ff 75 10             	pushl  0x10(%ebp)
  8014ad:	e8 54 00 00 00       	call   801506 <vcprintf>
	cprintf("\n");
  8014b2:	c7 04 24 9f 1f 80 00 	movl   $0x801f9f,(%esp)
  8014b9:	e8 99 00 00 00       	call   801557 <cprintf>
  8014be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014c1:	cc                   	int3   
  8014c2:	eb fd                	jmp    8014c1 <_panic+0x43>

008014c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014ce:	8b 13                	mov    (%ebx),%edx
  8014d0:	8d 42 01             	lea    0x1(%edx),%eax
  8014d3:	89 03                	mov    %eax,(%ebx)
  8014d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014e1:	75 1a                	jne    8014fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	68 ff 00 00 00       	push   $0xff
  8014eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8014ee:	50                   	push   %eax
  8014ef:	e8 ca ef ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  8014f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80150f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801516:	00 00 00 
	b.cnt = 0;
  801519:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801520:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	ff 75 08             	pushl  0x8(%ebp)
  801529:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	68 c4 14 80 00       	push   $0x8014c4
  801535:	e8 54 01 00 00       	call   80168e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801543:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	e8 6f ef ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  80154f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80155d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801560:	50                   	push   %eax
  801561:	ff 75 08             	pushl  0x8(%ebp)
  801564:	e8 9d ff ff ff       	call   801506 <vcprintf>
	va_end(ap);

	return cnt;
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 1c             	sub    $0x1c,%esp
  801574:	89 c7                	mov    %eax,%edi
  801576:	89 d6                	mov    %edx,%esi
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801581:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801584:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801587:	bb 00 00 00 00       	mov    $0x0,%ebx
  80158c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80158f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801592:	39 d3                	cmp    %edx,%ebx
  801594:	72 05                	jb     80159b <printnum+0x30>
  801596:	39 45 10             	cmp    %eax,0x10(%ebp)
  801599:	77 45                	ja     8015e0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	ff 75 18             	pushl  0x18(%ebp)
  8015a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015a7:	53                   	push   %ebx
  8015a8:	ff 75 10             	pushl  0x10(%ebp)
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ba:	e8 21 06 00 00       	call   801be0 <__udivdi3>
  8015bf:	83 c4 18             	add    $0x18,%esp
  8015c2:	52                   	push   %edx
  8015c3:	50                   	push   %eax
  8015c4:	89 f2                	mov    %esi,%edx
  8015c6:	89 f8                	mov    %edi,%eax
  8015c8:	e8 9e ff ff ff       	call   80156b <printnum>
  8015cd:	83 c4 20             	add    $0x20,%esp
  8015d0:	eb 18                	jmp    8015ea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	56                   	push   %esi
  8015d6:	ff 75 18             	pushl  0x18(%ebp)
  8015d9:	ff d7                	call   *%edi
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 03                	jmp    8015e3 <printnum+0x78>
  8015e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015e3:	83 eb 01             	sub    $0x1,%ebx
  8015e6:	85 db                	test   %ebx,%ebx
  8015e8:	7f e8                	jg     8015d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	56                   	push   %esi
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8015fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8015fd:	e8 0e 07 00 00       	call   801d10 <__umoddi3>
  801602:	83 c4 14             	add    $0x14,%esp
  801605:	0f be 80 d7 1f 80 00 	movsbl 0x801fd7(%eax),%eax
  80160c:	50                   	push   %eax
  80160d:	ff d7                	call   *%edi
}
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80161d:	83 fa 01             	cmp    $0x1,%edx
  801620:	7e 0e                	jle    801630 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801622:	8b 10                	mov    (%eax),%edx
  801624:	8d 4a 08             	lea    0x8(%edx),%ecx
  801627:	89 08                	mov    %ecx,(%eax)
  801629:	8b 02                	mov    (%edx),%eax
  80162b:	8b 52 04             	mov    0x4(%edx),%edx
  80162e:	eb 22                	jmp    801652 <getuint+0x38>
	else if (lflag)
  801630:	85 d2                	test   %edx,%edx
  801632:	74 10                	je     801644 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801634:	8b 10                	mov    (%eax),%edx
  801636:	8d 4a 04             	lea    0x4(%edx),%ecx
  801639:	89 08                	mov    %ecx,(%eax)
  80163b:	8b 02                	mov    (%edx),%eax
  80163d:	ba 00 00 00 00       	mov    $0x0,%edx
  801642:	eb 0e                	jmp    801652 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801644:	8b 10                	mov    (%eax),%edx
  801646:	8d 4a 04             	lea    0x4(%edx),%ecx
  801649:	89 08                	mov    %ecx,(%eax)
  80164b:	8b 02                	mov    (%edx),%eax
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80165a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80165e:	8b 10                	mov    (%eax),%edx
  801660:	3b 50 04             	cmp    0x4(%eax),%edx
  801663:	73 0a                	jae    80166f <sprintputch+0x1b>
		*b->buf++ = ch;
  801665:	8d 4a 01             	lea    0x1(%edx),%ecx
  801668:	89 08                	mov    %ecx,(%eax)
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	88 02                	mov    %al,(%edx)
}
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801677:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80167a:	50                   	push   %eax
  80167b:	ff 75 10             	pushl  0x10(%ebp)
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 05 00 00 00       	call   80168e <vprintfmt>
	va_end(ap);
}
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	57                   	push   %edi
  801692:	56                   	push   %esi
  801693:	53                   	push   %ebx
  801694:	83 ec 2c             	sub    $0x2c,%esp
  801697:	8b 75 08             	mov    0x8(%ebp),%esi
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80169d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016a0:	eb 12                	jmp    8016b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	0f 84 89 03 00 00    	je     801a33 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	53                   	push   %ebx
  8016ae:	50                   	push   %eax
  8016af:	ff d6                	call   *%esi
  8016b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016b4:	83 c7 01             	add    $0x1,%edi
  8016b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016bb:	83 f8 25             	cmp    $0x25,%eax
  8016be:	75 e2                	jne    8016a2 <vprintfmt+0x14>
  8016c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	eb 07                	jmp    8016e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8016e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e7:	8d 47 01             	lea    0x1(%edi),%eax
  8016ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ed:	0f b6 07             	movzbl (%edi),%eax
  8016f0:	0f b6 c8             	movzbl %al,%ecx
  8016f3:	83 e8 23             	sub    $0x23,%eax
  8016f6:	3c 55                	cmp    $0x55,%al
  8016f8:	0f 87 1a 03 00 00    	ja     801a18 <vprintfmt+0x38a>
  8016fe:	0f b6 c0             	movzbl %al,%eax
  801701:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  801708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80170b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80170f:	eb d6                	jmp    8016e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801714:	b8 00 00 00 00       	mov    $0x0,%eax
  801719:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80171c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80171f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801723:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801726:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801729:	83 fa 09             	cmp    $0x9,%edx
  80172c:	77 39                	ja     801767 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80172e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801731:	eb e9                	jmp    80171c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801733:	8b 45 14             	mov    0x14(%ebp),%eax
  801736:	8d 48 04             	lea    0x4(%eax),%ecx
  801739:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80173c:	8b 00                	mov    (%eax),%eax
  80173e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801744:	eb 27                	jmp    80176d <vprintfmt+0xdf>
  801746:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801749:	85 c0                	test   %eax,%eax
  80174b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801750:	0f 49 c8             	cmovns %eax,%ecx
  801753:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801759:	eb 8c                	jmp    8016e7 <vprintfmt+0x59>
  80175b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80175e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801765:	eb 80                	jmp    8016e7 <vprintfmt+0x59>
  801767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80176a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80176d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801771:	0f 89 70 ff ff ff    	jns    8016e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801777:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80177a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80177d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801784:	e9 5e ff ff ff       	jmp    8016e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801789:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80178f:	e9 53 ff ff ff       	jmp    8016e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801794:	8b 45 14             	mov    0x14(%ebp),%eax
  801797:	8d 50 04             	lea    0x4(%eax),%edx
  80179a:	89 55 14             	mov    %edx,0x14(%ebp)
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	ff 30                	pushl  (%eax)
  8017a3:	ff d6                	call   *%esi
			break;
  8017a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017ab:	e9 04 ff ff ff       	jmp    8016b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b3:	8d 50 04             	lea    0x4(%eax),%edx
  8017b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017b9:	8b 00                	mov    (%eax),%eax
  8017bb:	99                   	cltd   
  8017bc:	31 d0                	xor    %edx,%eax
  8017be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017c0:	83 f8 0f             	cmp    $0xf,%eax
  8017c3:	7f 0b                	jg     8017d0 <vprintfmt+0x142>
  8017c5:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  8017cc:	85 d2                	test   %edx,%edx
  8017ce:	75 18                	jne    8017e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017d0:	50                   	push   %eax
  8017d1:	68 ef 1f 80 00       	push   $0x801fef
  8017d6:	53                   	push   %ebx
  8017d7:	56                   	push   %esi
  8017d8:	e8 94 fe ff ff       	call   801671 <printfmt>
  8017dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017e3:	e9 cc fe ff ff       	jmp    8016b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8017e8:	52                   	push   %edx
  8017e9:	68 66 1f 80 00       	push   $0x801f66
  8017ee:	53                   	push   %ebx
  8017ef:	56                   	push   %esi
  8017f0:	e8 7c fe ff ff       	call   801671 <printfmt>
  8017f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017fb:	e9 b4 fe ff ff       	jmp    8016b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801800:	8b 45 14             	mov    0x14(%ebp),%eax
  801803:	8d 50 04             	lea    0x4(%eax),%edx
  801806:	89 55 14             	mov    %edx,0x14(%ebp)
  801809:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80180b:	85 ff                	test   %edi,%edi
  80180d:	b8 e8 1f 80 00       	mov    $0x801fe8,%eax
  801812:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801815:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801819:	0f 8e 94 00 00 00    	jle    8018b3 <vprintfmt+0x225>
  80181f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801823:	0f 84 98 00 00 00    	je     8018c1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	ff 75 d0             	pushl  -0x30(%ebp)
  80182f:	57                   	push   %edi
  801830:	e8 21 e9 ff ff       	call   800156 <strnlen>
  801835:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801838:	29 c1                	sub    %eax,%ecx
  80183a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80183d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801840:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801844:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801847:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80184a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80184c:	eb 0f                	jmp    80185d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	53                   	push   %ebx
  801852:	ff 75 e0             	pushl  -0x20(%ebp)
  801855:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801857:	83 ef 01             	sub    $0x1,%edi
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 ff                	test   %edi,%edi
  80185f:	7f ed                	jg     80184e <vprintfmt+0x1c0>
  801861:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801864:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801867:	85 c9                	test   %ecx,%ecx
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	0f 49 c1             	cmovns %ecx,%eax
  801871:	29 c1                	sub    %eax,%ecx
  801873:	89 75 08             	mov    %esi,0x8(%ebp)
  801876:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801879:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80187c:	89 cb                	mov    %ecx,%ebx
  80187e:	eb 4d                	jmp    8018cd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801880:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801884:	74 1b                	je     8018a1 <vprintfmt+0x213>
  801886:	0f be c0             	movsbl %al,%eax
  801889:	83 e8 20             	sub    $0x20,%eax
  80188c:	83 f8 5e             	cmp    $0x5e,%eax
  80188f:	76 10                	jbe    8018a1 <vprintfmt+0x213>
					putch('?', putdat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	6a 3f                	push   $0x3f
  801899:	ff 55 08             	call   *0x8(%ebp)
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb 0d                	jmp    8018ae <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	52                   	push   %edx
  8018a8:	ff 55 08             	call   *0x8(%ebp)
  8018ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ae:	83 eb 01             	sub    $0x1,%ebx
  8018b1:	eb 1a                	jmp    8018cd <vprintfmt+0x23f>
  8018b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018bf:	eb 0c                	jmp    8018cd <vprintfmt+0x23f>
  8018c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8018c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018cd:	83 c7 01             	add    $0x1,%edi
  8018d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d4:	0f be d0             	movsbl %al,%edx
  8018d7:	85 d2                	test   %edx,%edx
  8018d9:	74 23                	je     8018fe <vprintfmt+0x270>
  8018db:	85 f6                	test   %esi,%esi
  8018dd:	78 a1                	js     801880 <vprintfmt+0x1f2>
  8018df:	83 ee 01             	sub    $0x1,%esi
  8018e2:	79 9c                	jns    801880 <vprintfmt+0x1f2>
  8018e4:	89 df                	mov    %ebx,%edi
  8018e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018ec:	eb 18                	jmp    801906 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	6a 20                	push   $0x20
  8018f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018f6:	83 ef 01             	sub    $0x1,%edi
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	eb 08                	jmp    801906 <vprintfmt+0x278>
  8018fe:	89 df                	mov    %ebx,%edi
  801900:	8b 75 08             	mov    0x8(%ebp),%esi
  801903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801906:	85 ff                	test   %edi,%edi
  801908:	7f e4                	jg     8018ee <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80190d:	e9 a2 fd ff ff       	jmp    8016b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801912:	83 fa 01             	cmp    $0x1,%edx
  801915:	7e 16                	jle    80192d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801917:	8b 45 14             	mov    0x14(%ebp),%eax
  80191a:	8d 50 08             	lea    0x8(%eax),%edx
  80191d:	89 55 14             	mov    %edx,0x14(%ebp)
  801920:	8b 50 04             	mov    0x4(%eax),%edx
  801923:	8b 00                	mov    (%eax),%eax
  801925:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801928:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80192b:	eb 32                	jmp    80195f <vprintfmt+0x2d1>
	else if (lflag)
  80192d:	85 d2                	test   %edx,%edx
  80192f:	74 18                	je     801949 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801931:	8b 45 14             	mov    0x14(%ebp),%eax
  801934:	8d 50 04             	lea    0x4(%eax),%edx
  801937:	89 55 14             	mov    %edx,0x14(%ebp)
  80193a:	8b 00                	mov    (%eax),%eax
  80193c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80193f:	89 c1                	mov    %eax,%ecx
  801941:	c1 f9 1f             	sar    $0x1f,%ecx
  801944:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801947:	eb 16                	jmp    80195f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801949:	8b 45 14             	mov    0x14(%ebp),%eax
  80194c:	8d 50 04             	lea    0x4(%eax),%edx
  80194f:	89 55 14             	mov    %edx,0x14(%ebp)
  801952:	8b 00                	mov    (%eax),%eax
  801954:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801957:	89 c1                	mov    %eax,%ecx
  801959:	c1 f9 1f             	sar    $0x1f,%ecx
  80195c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80195f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801962:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801965:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80196a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80196e:	79 74                	jns    8019e4 <vprintfmt+0x356>
				putch('-', putdat);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	53                   	push   %ebx
  801974:	6a 2d                	push   $0x2d
  801976:	ff d6                	call   *%esi
				num = -(long long) num;
  801978:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80197b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80197e:	f7 d8                	neg    %eax
  801980:	83 d2 00             	adc    $0x0,%edx
  801983:	f7 da                	neg    %edx
  801985:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801988:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80198d:	eb 55                	jmp    8019e4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80198f:	8d 45 14             	lea    0x14(%ebp),%eax
  801992:	e8 83 fc ff ff       	call   80161a <getuint>
			base = 10;
  801997:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80199c:	eb 46                	jmp    8019e4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80199e:	8d 45 14             	lea    0x14(%ebp),%eax
  8019a1:	e8 74 fc ff ff       	call   80161a <getuint>
                        base = 8;
  8019a6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8019ab:	eb 37                	jmp    8019e4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	53                   	push   %ebx
  8019b1:	6a 30                	push   $0x30
  8019b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8019b5:	83 c4 08             	add    $0x8,%esp
  8019b8:	53                   	push   %ebx
  8019b9:	6a 78                	push   $0x78
  8019bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c0:	8d 50 04             	lea    0x4(%eax),%edx
  8019c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019c6:	8b 00                	mov    (%eax),%eax
  8019c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019d5:	eb 0d                	jmp    8019e4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019da:	e8 3b fc ff ff       	call   80161a <getuint>
			base = 16;
  8019df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8019eb:	57                   	push   %edi
  8019ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ef:	51                   	push   %ecx
  8019f0:	52                   	push   %edx
  8019f1:	50                   	push   %eax
  8019f2:	89 da                	mov    %ebx,%edx
  8019f4:	89 f0                	mov    %esi,%eax
  8019f6:	e8 70 fb ff ff       	call   80156b <printnum>
			break;
  8019fb:	83 c4 20             	add    $0x20,%esp
  8019fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a01:	e9 ae fc ff ff       	jmp    8016b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	53                   	push   %ebx
  801a0a:	51                   	push   %ecx
  801a0b:	ff d6                	call   *%esi
			break;
  801a0d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a13:	e9 9c fc ff ff       	jmp    8016b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	53                   	push   %ebx
  801a1c:	6a 25                	push   $0x25
  801a1e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	eb 03                	jmp    801a28 <vprintfmt+0x39a>
  801a25:	83 ef 01             	sub    $0x1,%edi
  801a28:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a2c:	75 f7                	jne    801a25 <vprintfmt+0x397>
  801a2e:	e9 81 fc ff ff       	jmp    8016b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 18             	sub    $0x18,%esp
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a4a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a4e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	74 26                	je     801a82 <vsnprintf+0x47>
  801a5c:	85 d2                	test   %edx,%edx
  801a5e:	7e 22                	jle    801a82 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a60:	ff 75 14             	pushl  0x14(%ebp)
  801a63:	ff 75 10             	pushl  0x10(%ebp)
  801a66:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a69:	50                   	push   %eax
  801a6a:	68 54 16 80 00       	push   $0x801654
  801a6f:	e8 1a fc ff ff       	call   80168e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a77:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	eb 05                	jmp    801a87 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a8f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a92:	50                   	push   %eax
  801a93:	ff 75 10             	pushl  0x10(%ebp)
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	ff 75 08             	pushl  0x8(%ebp)
  801a9c:	e8 9a ff ff ff       	call   801a3b <vsnprintf>
	va_end(ap);

	return rc;
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	8b 75 08             	mov    0x8(%ebp),%esi
  801aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ab1:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ab3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ab8:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	50                   	push   %eax
  801abf:	e8 66 ec ff ff       	call   80072a <sys_ipc_recv>

	if (r < 0) {
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	79 16                	jns    801ae1 <ipc_recv+0x3e>
		if (from_env_store)
  801acb:	85 f6                	test   %esi,%esi
  801acd:	74 06                	je     801ad5 <ipc_recv+0x32>
			*from_env_store = 0;
  801acf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ad5:	85 db                	test   %ebx,%ebx
  801ad7:	74 2c                	je     801b05 <ipc_recv+0x62>
			*perm_store = 0;
  801ad9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801adf:	eb 24                	jmp    801b05 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ae1:	85 f6                	test   %esi,%esi
  801ae3:	74 0a                	je     801aef <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ae5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aea:	8b 40 74             	mov    0x74(%eax),%eax
  801aed:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	74 0a                	je     801afd <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801af3:	a1 04 40 80 00       	mov    0x804004,%eax
  801af8:	8b 40 78             	mov    0x78(%eax),%eax
  801afb:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801afd:	a1 04 40 80 00       	mov    0x804004,%eax
  801b02:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801b1e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801b20:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b25:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801b28:	ff 75 14             	pushl  0x14(%ebp)
  801b2b:	53                   	push   %ebx
  801b2c:	56                   	push   %esi
  801b2d:	57                   	push   %edi
  801b2e:	e8 d4 eb ff ff       	call   800707 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b39:	75 07                	jne    801b42 <ipc_send+0x36>
			sys_yield();
  801b3b:	e8 1b ea ff ff       	call   80055b <sys_yield>
  801b40:	eb e6                	jmp    801b28 <ipc_send+0x1c>
		} else if (r < 0) {
  801b42:	85 c0                	test   %eax,%eax
  801b44:	79 12                	jns    801b58 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801b46:	50                   	push   %eax
  801b47:	68 e0 22 80 00       	push   $0x8022e0
  801b4c:	6a 51                	push   $0x51
  801b4e:	68 ed 22 80 00       	push   $0x8022ed
  801b53:	e8 26 f9 ff ff       	call   80147e <_panic>
		}
	}
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b74:	8b 52 50             	mov    0x50(%edx),%edx
  801b77:	39 ca                	cmp    %ecx,%edx
  801b79:	75 0d                	jne    801b88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b83:	8b 40 48             	mov    0x48(%eax),%eax
  801b86:	eb 0f                	jmp    801b97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b88:	83 c0 01             	add    $0x1,%eax
  801b8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b90:	75 d9                	jne    801b6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	c1 e8 16             	shr    $0x16,%eax
  801ba4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb0:	f6 c1 01             	test   $0x1,%cl
  801bb3:	74 1d                	je     801bd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb5:	c1 ea 0c             	shr    $0xc,%edx
  801bb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbf:	f6 c2 01             	test   $0x1,%dl
  801bc2:	74 0e                	je     801bd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc4:	c1 ea 0c             	shr    $0xc,%edx
  801bc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bce:	ef 
  801bcf:	0f b7 c0             	movzwl %ax,%eax
}
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    
  801bd4:	66 90                	xchg   %ax,%ax
  801bd6:	66 90                	xchg   %ax,%ax
  801bd8:	66 90                	xchg   %ax,%ax
  801bda:	66 90                	xchg   %ax,%ax
  801bdc:	66 90                	xchg   %ax,%ax
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
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
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
