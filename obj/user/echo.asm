
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
  800051:	68 c0 23 80 00       	push   $0x8023c0
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
  80008a:	68 c3 23 80 00       	push   $0x8023c3
  80008f:	6a 01                	push   $0x1
  800091:	e8 6f 0b 00 00       	call   800c05 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 53 0b 00 00       	call   800c05 <write>
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
  8000c7:	68 1c 25 80 00       	push   $0x80251c
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 32 0b 00 00       	call   800c05 <write>
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
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80012a:	e8 eb 08 00 00       	call   800a1a <close_all>
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
  800523:	68 cf 23 80 00       	push   $0x8023cf
  800528:	6a 23                	push   $0x23
  80052a:	68 ec 23 80 00       	push   $0x8023ec
  80052f:	e8 95 14 00 00       	call   8019c9 <_panic>

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
  8005a4:	68 cf 23 80 00       	push   $0x8023cf
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 ec 23 80 00       	push   $0x8023ec
  8005b0:	e8 14 14 00 00       	call   8019c9 <_panic>

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
  8005e6:	68 cf 23 80 00       	push   $0x8023cf
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 ec 23 80 00       	push   $0x8023ec
  8005f2:	e8 d2 13 00 00       	call   8019c9 <_panic>

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
  800628:	68 cf 23 80 00       	push   $0x8023cf
  80062d:	6a 23                	push   $0x23
  80062f:	68 ec 23 80 00       	push   $0x8023ec
  800634:	e8 90 13 00 00       	call   8019c9 <_panic>

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
  80066a:	68 cf 23 80 00       	push   $0x8023cf
  80066f:	6a 23                	push   $0x23
  800671:	68 ec 23 80 00       	push   $0x8023ec
  800676:	e8 4e 13 00 00       	call   8019c9 <_panic>

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
  8006ac:	68 cf 23 80 00       	push   $0x8023cf
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 ec 23 80 00       	push   $0x8023ec
  8006b8:	e8 0c 13 00 00       	call   8019c9 <_panic>

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
  8006ee:	68 cf 23 80 00       	push   $0x8023cf
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 ec 23 80 00       	push   $0x8023ec
  8006fa:	e8 ca 12 00 00       	call   8019c9 <_panic>

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
  800752:	68 cf 23 80 00       	push   $0x8023cf
  800757:	6a 23                	push   $0x23
  800759:	68 ec 23 80 00       	push   $0x8023ec
  80075e:	e8 66 12 00 00       	call   8019c9 <_panic>

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

0080076b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 d3                	mov    %edx,%ebx
  80077f:	89 d7                	mov    %edx,%edi
  800781:	89 d6                	mov    %edx,%esi
  800783:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	57                   	push   %edi
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800793:	bb 00 00 00 00       	mov    $0x0,%ebx
  800798:	b8 0f 00 00 00       	mov    $0xf,%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a3:	89 df                	mov    %ebx,%edi
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	7e 17                	jle    8007c4 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	50                   	push   %eax
  8007b1:	6a 0f                	push   $0xf
  8007b3:	68 cf 23 80 00       	push   $0x8023cf
  8007b8:	6a 23                	push   $0x23
  8007ba:	68 ec 23 80 00       	push   $0x8023ec
  8007bf:	e8 05 12 00 00       	call   8019c9 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8007c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5f                   	pop    %edi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	57                   	push   %edi
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e5:	89 df                	mov    %ebx,%edi
  8007e7:	89 de                	mov    %ebx,%esi
  8007e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	7e 17                	jle    800806 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ef:	83 ec 0c             	sub    $0xc,%esp
  8007f2:	50                   	push   %eax
  8007f3:	6a 10                	push   $0x10
  8007f5:	68 cf 23 80 00       	push   $0x8023cf
  8007fa:	6a 23                	push   $0x23
  8007fc:	68 ec 23 80 00       	push   $0x8023ec
  800801:	e8 c3 11 00 00       	call   8019c9 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	57                   	push   %edi
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800817:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081c:	b8 11 00 00 00       	mov    $0x11,%eax
  800821:	8b 55 08             	mov    0x8(%ebp),%edx
  800824:	89 cb                	mov    %ecx,%ebx
  800826:	89 cf                	mov    %ecx,%edi
  800828:	89 ce                	mov    %ecx,%esi
  80082a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80082c:	85 c0                	test   %eax,%eax
  80082e:	7e 17                	jle    800847 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	50                   	push   %eax
  800834:	6a 11                	push   $0x11
  800836:	68 cf 23 80 00       	push   $0x8023cf
  80083b:	6a 23                	push   $0x23
  80083d:	68 ec 23 80 00       	push   $0x8023ec
  800842:	e8 82 11 00 00       	call   8019c9 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800847:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5f                   	pop    %edi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	05 00 00 00 30       	add    $0x30000000,%eax
  80085a:	c1 e8 0c             	shr    $0xc,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	05 00 00 00 30       	add    $0x30000000,%eax
  80086a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80086f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800881:	89 c2                	mov    %eax,%edx
  800883:	c1 ea 16             	shr    $0x16,%edx
  800886:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80088d:	f6 c2 01             	test   $0x1,%dl
  800890:	74 11                	je     8008a3 <fd_alloc+0x2d>
  800892:	89 c2                	mov    %eax,%edx
  800894:	c1 ea 0c             	shr    $0xc,%edx
  800897:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80089e:	f6 c2 01             	test   $0x1,%dl
  8008a1:	75 09                	jne    8008ac <fd_alloc+0x36>
			*fd_store = fd;
  8008a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	eb 17                	jmp    8008c3 <fd_alloc+0x4d>
  8008ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8008b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8008b6:	75 c9                	jne    800881 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8008b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8008be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8008cb:	83 f8 1f             	cmp    $0x1f,%eax
  8008ce:	77 36                	ja     800906 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8008d0:	c1 e0 0c             	shl    $0xc,%eax
  8008d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	c1 ea 16             	shr    $0x16,%edx
  8008dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008e4:	f6 c2 01             	test   $0x1,%dl
  8008e7:	74 24                	je     80090d <fd_lookup+0x48>
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	c1 ea 0c             	shr    $0xc,%edx
  8008ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008f5:	f6 c2 01             	test   $0x1,%dl
  8008f8:	74 1a                	je     800914 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800904:	eb 13                	jmp    800919 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800906:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090b:	eb 0c                	jmp    800919 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80090d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800912:	eb 05                	jmp    800919 <fd_lookup+0x54>
  800914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800924:	ba 78 24 80 00       	mov    $0x802478,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800929:	eb 13                	jmp    80093e <dev_lookup+0x23>
  80092b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80092e:	39 08                	cmp    %ecx,(%eax)
  800930:	75 0c                	jne    80093e <dev_lookup+0x23>
			*dev = devtab[i];
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	89 01                	mov    %eax,(%ecx)
			return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
  80093c:	eb 2e                	jmp    80096c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80093e:	8b 02                	mov    (%edx),%eax
  800940:	85 c0                	test   %eax,%eax
  800942:	75 e7                	jne    80092b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800944:	a1 08 40 80 00       	mov    0x804008,%eax
  800949:	8b 40 48             	mov    0x48(%eax),%eax
  80094c:	83 ec 04             	sub    $0x4,%esp
  80094f:	51                   	push   %ecx
  800950:	50                   	push   %eax
  800951:	68 fc 23 80 00       	push   $0x8023fc
  800956:	e8 47 11 00 00       	call   801aa2 <cprintf>
	*dev = 0;
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800964:	83 c4 10             	add    $0x10,%esp
  800967:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	83 ec 10             	sub    $0x10,%esp
  800976:	8b 75 08             	mov    0x8(%ebp),%esi
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80097c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097f:	50                   	push   %eax
  800980:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800986:	c1 e8 0c             	shr    $0xc,%eax
  800989:	50                   	push   %eax
  80098a:	e8 36 ff ff ff       	call   8008c5 <fd_lookup>
  80098f:	83 c4 08             	add    $0x8,%esp
  800992:	85 c0                	test   %eax,%eax
  800994:	78 05                	js     80099b <fd_close+0x2d>
	    || fd != fd2)
  800996:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800999:	74 0c                	je     8009a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80099b:	84 db                	test   %bl,%bl
  80099d:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a2:	0f 44 c2             	cmove  %edx,%eax
  8009a5:	eb 41                	jmp    8009e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009ad:	50                   	push   %eax
  8009ae:	ff 36                	pushl  (%esi)
  8009b0:	e8 66 ff ff ff       	call   80091b <dev_lookup>
  8009b5:	89 c3                	mov    %eax,%ebx
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	85 c0                	test   %eax,%eax
  8009bc:	78 1a                	js     8009d8 <fd_close+0x6a>
		if (dev->dev_close)
  8009be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8009c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	74 0b                	je     8009d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	56                   	push   %esi
  8009d1:	ff d0                	call   *%eax
  8009d3:	89 c3                	mov    %eax,%ebx
  8009d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	56                   	push   %esi
  8009dc:	6a 00                	push   $0x0
  8009de:	e8 1c fc ff ff       	call   8005ff <sys_page_unmap>
	return r;
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	89 d8                	mov    %ebx,%eax
}
  8009e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f8:	50                   	push   %eax
  8009f9:	ff 75 08             	pushl  0x8(%ebp)
  8009fc:	e8 c4 fe ff ff       	call   8008c5 <fd_lookup>
  800a01:	83 c4 08             	add    $0x8,%esp
  800a04:	85 c0                	test   %eax,%eax
  800a06:	78 10                	js     800a18 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	6a 01                	push   $0x1
  800a0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a10:	e8 59 ff ff ff       	call   80096e <fd_close>
  800a15:	83 c4 10             	add    $0x10,%esp
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <close_all>:

void
close_all(void)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a21:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a26:	83 ec 0c             	sub    $0xc,%esp
  800a29:	53                   	push   %ebx
  800a2a:	e8 c0 ff ff ff       	call   8009ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a2f:	83 c3 01             	add    $0x1,%ebx
  800a32:	83 c4 10             	add    $0x10,%esp
  800a35:	83 fb 20             	cmp    $0x20,%ebx
  800a38:	75 ec                	jne    800a26 <close_all+0xc>
		close(i);
}
  800a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	83 ec 2c             	sub    $0x2c,%esp
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a4e:	50                   	push   %eax
  800a4f:	ff 75 08             	pushl  0x8(%ebp)
  800a52:	e8 6e fe ff ff       	call   8008c5 <fd_lookup>
  800a57:	83 c4 08             	add    $0x8,%esp
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	0f 88 c1 00 00 00    	js     800b23 <dup+0xe4>
		return r;
	close(newfdnum);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	56                   	push   %esi
  800a66:	e8 84 ff ff ff       	call   8009ef <close>

	newfd = INDEX2FD(newfdnum);
  800a6b:	89 f3                	mov    %esi,%ebx
  800a6d:	c1 e3 0c             	shl    $0xc,%ebx
  800a70:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a76:	83 c4 04             	add    $0x4,%esp
  800a79:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a7c:	e8 de fd ff ff       	call   80085f <fd2data>
  800a81:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800a83:	89 1c 24             	mov    %ebx,(%esp)
  800a86:	e8 d4 fd ff ff       	call   80085f <fd2data>
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a91:	89 f8                	mov    %edi,%eax
  800a93:	c1 e8 16             	shr    $0x16,%eax
  800a96:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a9d:	a8 01                	test   $0x1,%al
  800a9f:	74 37                	je     800ad8 <dup+0x99>
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	c1 e8 0c             	shr    $0xc,%eax
  800aa6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800aad:	f6 c2 01             	test   $0x1,%dl
  800ab0:	74 26                	je     800ad8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ab2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	25 07 0e 00 00       	and    $0xe07,%eax
  800ac1:	50                   	push   %eax
  800ac2:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ac5:	6a 00                	push   $0x0
  800ac7:	57                   	push   %edi
  800ac8:	6a 00                	push   $0x0
  800aca:	e8 ee fa ff ff       	call   8005bd <sys_page_map>
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	83 c4 20             	add    $0x20,%esp
  800ad4:	85 c0                	test   %eax,%eax
  800ad6:	78 2e                	js     800b06 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ad8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800adb:	89 d0                	mov    %edx,%eax
  800add:	c1 e8 0c             	shr    $0xc,%eax
  800ae0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	25 07 0e 00 00       	and    $0xe07,%eax
  800aef:	50                   	push   %eax
  800af0:	53                   	push   %ebx
  800af1:	6a 00                	push   $0x0
  800af3:	52                   	push   %edx
  800af4:	6a 00                	push   $0x0
  800af6:	e8 c2 fa ff ff       	call   8005bd <sys_page_map>
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b00:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b02:	85 ff                	test   %edi,%edi
  800b04:	79 1d                	jns    800b23 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	53                   	push   %ebx
  800b0a:	6a 00                	push   $0x0
  800b0c:	e8 ee fa ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b11:	83 c4 08             	add    $0x8,%esp
  800b14:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b17:	6a 00                	push   $0x0
  800b19:	e8 e1 fa ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	89 f8                	mov    %edi,%eax
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 14             	sub    $0x14,%esp
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	53                   	push   %ebx
  800b3a:	e8 86 fd ff ff       	call   8008c5 <fd_lookup>
  800b3f:	83 c4 08             	add    $0x8,%esp
  800b42:	89 c2                	mov    %eax,%edx
  800b44:	85 c0                	test   %eax,%eax
  800b46:	78 6d                	js     800bb5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4e:	50                   	push   %eax
  800b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b52:	ff 30                	pushl  (%eax)
  800b54:	e8 c2 fd ff ff       	call   80091b <dev_lookup>
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	78 4c                	js     800bac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b63:	8b 42 08             	mov    0x8(%edx),%eax
  800b66:	83 e0 03             	and    $0x3,%eax
  800b69:	83 f8 01             	cmp    $0x1,%eax
  800b6c:	75 21                	jne    800b8f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b6e:	a1 08 40 80 00       	mov    0x804008,%eax
  800b73:	8b 40 48             	mov    0x48(%eax),%eax
  800b76:	83 ec 04             	sub    $0x4,%esp
  800b79:	53                   	push   %ebx
  800b7a:	50                   	push   %eax
  800b7b:	68 3d 24 80 00       	push   $0x80243d
  800b80:	e8 1d 0f 00 00       	call   801aa2 <cprintf>
		return -E_INVAL;
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b8d:	eb 26                	jmp    800bb5 <read+0x8a>
	}
	if (!dev->dev_read)
  800b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b92:	8b 40 08             	mov    0x8(%eax),%eax
  800b95:	85 c0                	test   %eax,%eax
  800b97:	74 17                	je     800bb0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b99:	83 ec 04             	sub    $0x4,%esp
  800b9c:	ff 75 10             	pushl  0x10(%ebp)
  800b9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ba2:	52                   	push   %edx
  800ba3:	ff d0                	call   *%eax
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	eb 09                	jmp    800bb5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	eb 05                	jmp    800bb5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800bb0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800bb5:	89 d0                	mov    %edx,%eax
  800bb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	eb 21                	jmp    800bf3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bd2:	83 ec 04             	sub    $0x4,%esp
  800bd5:	89 f0                	mov    %esi,%eax
  800bd7:	29 d8                	sub    %ebx,%eax
  800bd9:	50                   	push   %eax
  800bda:	89 d8                	mov    %ebx,%eax
  800bdc:	03 45 0c             	add    0xc(%ebp),%eax
  800bdf:	50                   	push   %eax
  800be0:	57                   	push   %edi
  800be1:	e8 45 ff ff ff       	call   800b2b <read>
		if (m < 0)
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	85 c0                	test   %eax,%eax
  800beb:	78 10                	js     800bfd <readn+0x41>
			return m;
		if (m == 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	74 0a                	je     800bfb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bf1:	01 c3                	add    %eax,%ebx
  800bf3:	39 f3                	cmp    %esi,%ebx
  800bf5:	72 db                	jb     800bd2 <readn+0x16>
  800bf7:	89 d8                	mov    %ebx,%eax
  800bf9:	eb 02                	jmp    800bfd <readn+0x41>
  800bfb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	53                   	push   %ebx
  800c09:	83 ec 14             	sub    $0x14,%esp
  800c0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c12:	50                   	push   %eax
  800c13:	53                   	push   %ebx
  800c14:	e8 ac fc ff ff       	call   8008c5 <fd_lookup>
  800c19:	83 c4 08             	add    $0x8,%esp
  800c1c:	89 c2                	mov    %eax,%edx
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	78 68                	js     800c8a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c28:	50                   	push   %eax
  800c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2c:	ff 30                	pushl  (%eax)
  800c2e:	e8 e8 fc ff ff       	call   80091b <dev_lookup>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	85 c0                	test   %eax,%eax
  800c38:	78 47                	js     800c81 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c41:	75 21                	jne    800c64 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c43:	a1 08 40 80 00       	mov    0x804008,%eax
  800c48:	8b 40 48             	mov    0x48(%eax),%eax
  800c4b:	83 ec 04             	sub    $0x4,%esp
  800c4e:	53                   	push   %ebx
  800c4f:	50                   	push   %eax
  800c50:	68 59 24 80 00       	push   $0x802459
  800c55:	e8 48 0e 00 00       	call   801aa2 <cprintf>
		return -E_INVAL;
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c62:	eb 26                	jmp    800c8a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c67:	8b 52 0c             	mov    0xc(%edx),%edx
  800c6a:	85 d2                	test   %edx,%edx
  800c6c:	74 17                	je     800c85 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c6e:	83 ec 04             	sub    $0x4,%esp
  800c71:	ff 75 10             	pushl  0x10(%ebp)
  800c74:	ff 75 0c             	pushl  0xc(%ebp)
  800c77:	50                   	push   %eax
  800c78:	ff d2                	call   *%edx
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	eb 09                	jmp    800c8a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	eb 05                	jmp    800c8a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c85:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800c8a:	89 d0                	mov    %edx,%eax
  800c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c97:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c9a:	50                   	push   %eax
  800c9b:	ff 75 08             	pushl  0x8(%ebp)
  800c9e:	e8 22 fc ff ff       	call   8008c5 <fd_lookup>
  800ca3:	83 c4 08             	add    $0x8,%esp
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	78 0e                	js     800cb8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800caa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 14             	sub    $0x14,%esp
  800cc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cc7:	50                   	push   %eax
  800cc8:	53                   	push   %ebx
  800cc9:	e8 f7 fb ff ff       	call   8008c5 <fd_lookup>
  800cce:	83 c4 08             	add    $0x8,%esp
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	78 65                	js     800d3c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cd7:	83 ec 08             	sub    $0x8,%esp
  800cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cdd:	50                   	push   %eax
  800cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce1:	ff 30                	pushl  (%eax)
  800ce3:	e8 33 fc ff ff       	call   80091b <dev_lookup>
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	78 44                	js     800d33 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cf6:	75 21                	jne    800d19 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cf8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cfd:	8b 40 48             	mov    0x48(%eax),%eax
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	53                   	push   %ebx
  800d04:	50                   	push   %eax
  800d05:	68 1c 24 80 00       	push   $0x80241c
  800d0a:	e8 93 0d 00 00       	call   801aa2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d17:	eb 23                	jmp    800d3c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d1c:	8b 52 18             	mov    0x18(%edx),%edx
  800d1f:	85 d2                	test   %edx,%edx
  800d21:	74 14                	je     800d37 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d23:	83 ec 08             	sub    $0x8,%esp
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	50                   	push   %eax
  800d2a:	ff d2                	call   *%edx
  800d2c:	89 c2                	mov    %eax,%edx
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	eb 09                	jmp    800d3c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	eb 05                	jmp    800d3c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d37:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800d3c:	89 d0                	mov    %edx,%eax
  800d3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	83 ec 14             	sub    $0x14,%esp
  800d4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d50:	50                   	push   %eax
  800d51:	ff 75 08             	pushl  0x8(%ebp)
  800d54:	e8 6c fb ff ff       	call   8008c5 <fd_lookup>
  800d59:	83 c4 08             	add    $0x8,%esp
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 58                	js     800dba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d68:	50                   	push   %eax
  800d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6c:	ff 30                	pushl  (%eax)
  800d6e:	e8 a8 fb ff ff       	call   80091b <dev_lookup>
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	78 37                	js     800db1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d81:	74 32                	je     800db5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d83:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d86:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d8d:	00 00 00 
	stat->st_isdir = 0;
  800d90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d97:	00 00 00 
	stat->st_dev = dev;
  800d9a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800da0:	83 ec 08             	sub    $0x8,%esp
  800da3:	53                   	push   %ebx
  800da4:	ff 75 f0             	pushl  -0x10(%ebp)
  800da7:	ff 50 14             	call   *0x14(%eax)
  800daa:	89 c2                	mov    %eax,%edx
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	eb 09                	jmp    800dba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	eb 05                	jmp    800dba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800db5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800dba:	89 d0                	mov    %edx,%eax
  800dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	6a 00                	push   $0x0
  800dcb:	ff 75 08             	pushl  0x8(%ebp)
  800dce:	e8 0c 02 00 00       	call   800fdf <open>
  800dd3:	89 c3                	mov    %eax,%ebx
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	78 1b                	js     800df7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ddc:	83 ec 08             	sub    $0x8,%esp
  800ddf:	ff 75 0c             	pushl  0xc(%ebp)
  800de2:	50                   	push   %eax
  800de3:	e8 5b ff ff ff       	call   800d43 <fstat>
  800de8:	89 c6                	mov    %eax,%esi
	close(fd);
  800dea:	89 1c 24             	mov    %ebx,(%esp)
  800ded:	e8 fd fb ff ff       	call   8009ef <close>
	return r;
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	89 f0                	mov    %esi,%eax
}
  800df7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	89 c6                	mov    %eax,%esi
  800e05:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e07:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e0e:	75 12                	jne    800e22 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	6a 01                	push   $0x1
  800e15:	e8 91 12 00 00       	call   8020ab <ipc_find_env>
  800e1a:	a3 00 40 80 00       	mov    %eax,0x804000
  800e1f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e22:	6a 07                	push   $0x7
  800e24:	68 00 50 80 00       	push   $0x805000
  800e29:	56                   	push   %esi
  800e2a:	ff 35 00 40 80 00    	pushl  0x804000
  800e30:	e8 22 12 00 00       	call   802057 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e35:	83 c4 0c             	add    $0xc,%esp
  800e38:	6a 00                	push   $0x0
  800e3a:	53                   	push   %ebx
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 ac 11 00 00       	call   801fee <ipc_recv>
}
  800e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	8b 40 0c             	mov    0xc(%eax),%eax
  800e55:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6c:	e8 8d ff ff ff       	call   800dfe <fsipc>
}
  800e71:	c9                   	leave  
  800e72:	c3                   	ret    

00800e73 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e7f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8e:	e8 6b ff ff ff       	call   800dfe <fsipc>
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	8b 40 0c             	mov    0xc(%eax),%eax
  800ea5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb4:	e8 45 ff ff ff       	call   800dfe <fsipc>
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 2c                	js     800ee9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	68 00 50 80 00       	push   $0x805000
  800ec5:	53                   	push   %ebx
  800ec6:	e8 ac f2 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ecb:	a1 80 50 80 00       	mov    0x805080,%eax
  800ed0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ed6:	a1 84 50 80 00       	mov    0x805084,%eax
  800edb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	8b 52 0c             	mov    0xc(%edx),%edx
  800efe:	89 15 00 50 80 00    	mov    %edx,0x805000
  800f04:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f09:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800f0e:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800f11:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800f17:	53                   	push   %ebx
  800f18:	ff 75 0c             	pushl  0xc(%ebp)
  800f1b:	68 08 50 80 00       	push   $0x805008
  800f20:	e8 e4 f3 ff ff       	call   800309 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800f25:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800f2f:	e8 ca fe ff ff       	call   800dfe <fsipc>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 1d                	js     800f58 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800f3b:	39 d8                	cmp    %ebx,%eax
  800f3d:	76 19                	jbe    800f58 <devfile_write+0x6a>
  800f3f:	68 8c 24 80 00       	push   $0x80248c
  800f44:	68 98 24 80 00       	push   $0x802498
  800f49:	68 a5 00 00 00       	push   $0xa5
  800f4e:	68 ad 24 80 00       	push   $0x8024ad
  800f53:	e8 71 0a 00 00       	call   8019c9 <_panic>
	return r;
}
  800f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
  800f62:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	8b 40 0c             	mov    0xc(%eax),%eax
  800f6b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f70:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f76:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800f80:	e8 79 fe ff ff       	call   800dfe <fsipc>
  800f85:	89 c3                	mov    %eax,%ebx
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 4b                	js     800fd6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800f8b:	39 c6                	cmp    %eax,%esi
  800f8d:	73 16                	jae    800fa5 <devfile_read+0x48>
  800f8f:	68 b8 24 80 00       	push   $0x8024b8
  800f94:	68 98 24 80 00       	push   $0x802498
  800f99:	6a 7c                	push   $0x7c
  800f9b:	68 ad 24 80 00       	push   $0x8024ad
  800fa0:	e8 24 0a 00 00       	call   8019c9 <_panic>
	assert(r <= PGSIZE);
  800fa5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800faa:	7e 16                	jle    800fc2 <devfile_read+0x65>
  800fac:	68 bf 24 80 00       	push   $0x8024bf
  800fb1:	68 98 24 80 00       	push   $0x802498
  800fb6:	6a 7d                	push   $0x7d
  800fb8:	68 ad 24 80 00       	push   $0x8024ad
  800fbd:	e8 07 0a 00 00       	call   8019c9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	50                   	push   %eax
  800fc6:	68 00 50 80 00       	push   $0x805000
  800fcb:	ff 75 0c             	pushl  0xc(%ebp)
  800fce:	e8 36 f3 ff ff       	call   800309 <memmove>
	return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
}
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 20             	sub    $0x20,%esp
  800fe6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800fe9:	53                   	push   %ebx
  800fea:	e8 4f f1 ff ff       	call   80013e <strlen>
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ff7:	7f 67                	jg     801060 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	e8 71 f8 ff ff       	call   800876 <fd_alloc>
  801005:	83 c4 10             	add    $0x10,%esp
		return r;
  801008:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 57                	js     801065 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	53                   	push   %ebx
  801012:	68 00 50 80 00       	push   $0x805000
  801017:	e8 5b f1 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80101c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801024:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801027:	b8 01 00 00 00       	mov    $0x1,%eax
  80102c:	e8 cd fd ff ff       	call   800dfe <fsipc>
  801031:	89 c3                	mov    %eax,%ebx
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 14                	jns    80104e <open+0x6f>
		fd_close(fd, 0);
  80103a:	83 ec 08             	sub    $0x8,%esp
  80103d:	6a 00                	push   $0x0
  80103f:	ff 75 f4             	pushl  -0xc(%ebp)
  801042:	e8 27 f9 ff ff       	call   80096e <fd_close>
		return r;
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	89 da                	mov    %ebx,%edx
  80104c:	eb 17                	jmp    801065 <open+0x86>
	}

	return fd2num(fd);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	ff 75 f4             	pushl  -0xc(%ebp)
  801054:	e8 f6 f7 ff ff       	call   80084f <fd2num>
  801059:	89 c2                	mov    %eax,%edx
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	eb 05                	jmp    801065 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801060:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801065:	89 d0                	mov    %edx,%eax
  801067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801072:	ba 00 00 00 00       	mov    $0x0,%edx
  801077:	b8 08 00 00 00       	mov    $0x8,%eax
  80107c:	e8 7d fd ff ff       	call   800dfe <fsipc>
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801089:	68 cb 24 80 00       	push   $0x8024cb
  80108e:	ff 75 0c             	pushl  0xc(%ebp)
  801091:	e8 e1 f0 ff ff       	call   800177 <strcpy>
	return 0;
}
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 10             	sub    $0x10,%esp
  8010a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8010a7:	53                   	push   %ebx
  8010a8:	e8 37 10 00 00       	call   8020e4 <pageref>
  8010ad:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8010b0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8010b5:	83 f8 01             	cmp    $0x1,%eax
  8010b8:	75 10                	jne    8010ca <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	ff 73 0c             	pushl  0xc(%ebx)
  8010c0:	e8 c0 02 00 00       	call   801385 <nsipc_close>
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8010d7:	6a 00                	push   $0x0
  8010d9:	ff 75 10             	pushl  0x10(%ebp)
  8010dc:	ff 75 0c             	pushl  0xc(%ebp)
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	ff 70 0c             	pushl  0xc(%eax)
  8010e5:	e8 78 03 00 00       	call   801462 <nsipc_send>
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8010f2:	6a 00                	push   $0x0
  8010f4:	ff 75 10             	pushl  0x10(%ebp)
  8010f7:	ff 75 0c             	pushl  0xc(%ebp)
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	ff 70 0c             	pushl  0xc(%eax)
  801100:	e8 f1 02 00 00       	call   8013f6 <nsipc_recv>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80110d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801110:	52                   	push   %edx
  801111:	50                   	push   %eax
  801112:	e8 ae f7 ff ff       	call   8008c5 <fd_lookup>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 17                	js     801135 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80111e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801121:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801127:	39 08                	cmp    %ecx,(%eax)
  801129:	75 05                	jne    801130 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80112b:	8b 40 0c             	mov    0xc(%eax),%eax
  80112e:	eb 05                	jmp    801135 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801130:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 1c             	sub    $0x1c,%esp
  80113f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	e8 2c f7 ff ff       	call   800876 <fd_alloc>
  80114a:	89 c3                	mov    %eax,%ebx
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 1b                	js     80116e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	68 07 04 00 00       	push   $0x407
  80115b:	ff 75 f4             	pushl  -0xc(%ebp)
  80115e:	6a 00                	push   $0x0
  801160:	e8 15 f4 ff ff       	call   80057a <sys_page_alloc>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 10                	jns    80117e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	56                   	push   %esi
  801172:	e8 0e 02 00 00       	call   801385 <nsipc_close>
		return r;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	eb 24                	jmp    8011a2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80117e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801187:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801193:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	50                   	push   %eax
  80119a:	e8 b0 f6 ff ff       	call   80084f <fd2num>
  80119f:	83 c4 10             	add    $0x10,%esp
}
  8011a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	e8 50 ff ff ff       	call   801107 <fd2sockid>
		return r;
  8011b7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 1f                	js     8011dc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8011bd:	83 ec 04             	sub    $0x4,%esp
  8011c0:	ff 75 10             	pushl  0x10(%ebp)
  8011c3:	ff 75 0c             	pushl  0xc(%ebp)
  8011c6:	50                   	push   %eax
  8011c7:	e8 12 01 00 00       	call   8012de <nsipc_accept>
  8011cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8011cf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 07                	js     8011dc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8011d5:	e8 5d ff ff ff       	call   801137 <alloc_sockfd>
  8011da:	89 c1                	mov    %eax,%ecx
}
  8011dc:	89 c8                	mov    %ecx,%eax
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	e8 19 ff ff ff       	call   801107 <fd2sockid>
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 12                	js     801204 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	ff 75 10             	pushl  0x10(%ebp)
  8011f8:	ff 75 0c             	pushl  0xc(%ebp)
  8011fb:	50                   	push   %eax
  8011fc:	e8 2d 01 00 00       	call   80132e <nsipc_bind>
  801201:	83 c4 10             	add    $0x10,%esp
}
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <shutdown>:

int
shutdown(int s, int how)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80120c:	8b 45 08             	mov    0x8(%ebp),%eax
  80120f:	e8 f3 fe ff ff       	call   801107 <fd2sockid>
  801214:	85 c0                	test   %eax,%eax
  801216:	78 0f                	js     801227 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	ff 75 0c             	pushl  0xc(%ebp)
  80121e:	50                   	push   %eax
  80121f:	e8 3f 01 00 00       	call   801363 <nsipc_shutdown>
  801224:	83 c4 10             	add    $0x10,%esp
}
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	e8 d0 fe ff ff       	call   801107 <fd2sockid>
  801237:	85 c0                	test   %eax,%eax
  801239:	78 12                	js     80124d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	ff 75 10             	pushl  0x10(%ebp)
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	50                   	push   %eax
  801245:	e8 55 01 00 00       	call   80139f <nsipc_connect>
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <listen>:

int
listen(int s, int backlog)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	e8 aa fe ff ff       	call   801107 <fd2sockid>
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 0f                	js     801270 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	ff 75 0c             	pushl  0xc(%ebp)
  801267:	50                   	push   %eax
  801268:	e8 67 01 00 00       	call   8013d4 <nsipc_listen>
  80126d:	83 c4 10             	add    $0x10,%esp
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801278:	ff 75 10             	pushl  0x10(%ebp)
  80127b:	ff 75 0c             	pushl  0xc(%ebp)
  80127e:	ff 75 08             	pushl  0x8(%ebp)
  801281:	e8 3a 02 00 00       	call   8014c0 <nsipc_socket>
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 05                	js     801292 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80128d:	e8 a5 fe ff ff       	call   801137 <alloc_sockfd>
}
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80129d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8012a4:	75 12                	jne    8012b8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8012a6:	83 ec 0c             	sub    $0xc,%esp
  8012a9:	6a 02                	push   $0x2
  8012ab:	e8 fb 0d 00 00       	call   8020ab <ipc_find_env>
  8012b0:	a3 04 40 80 00       	mov    %eax,0x804004
  8012b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8012b8:	6a 07                	push   $0x7
  8012ba:	68 00 60 80 00       	push   $0x806000
  8012bf:	53                   	push   %ebx
  8012c0:	ff 35 04 40 80 00    	pushl  0x804004
  8012c6:	e8 8c 0d 00 00       	call   802057 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8012cb:	83 c4 0c             	add    $0xc,%esp
  8012ce:	6a 00                	push   $0x0
  8012d0:	6a 00                	push   $0x0
  8012d2:	6a 00                	push   $0x0
  8012d4:	e8 15 0d 00 00       	call   801fee <ipc_recv>
}
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8012ee:	8b 06                	mov    (%esi),%eax
  8012f0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8012f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8012fa:	e8 95 ff ff ff       	call   801294 <nsipc>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	85 c0                	test   %eax,%eax
  801303:	78 20                	js     801325 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801305:	83 ec 04             	sub    $0x4,%esp
  801308:	ff 35 10 60 80 00    	pushl  0x806010
  80130e:	68 00 60 80 00       	push   $0x806000
  801313:	ff 75 0c             	pushl  0xc(%ebp)
  801316:	e8 ee ef ff ff       	call   800309 <memmove>
		*addrlen = ret->ret_addrlen;
  80131b:	a1 10 60 80 00       	mov    0x806010,%eax
  801320:	89 06                	mov    %eax,(%esi)
  801322:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801325:	89 d8                	mov    %ebx,%eax
  801327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	53                   	push   %ebx
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801340:	53                   	push   %ebx
  801341:	ff 75 0c             	pushl  0xc(%ebp)
  801344:	68 04 60 80 00       	push   $0x806004
  801349:	e8 bb ef ff ff       	call   800309 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80134e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801354:	b8 02 00 00 00       	mov    $0x2,%eax
  801359:	e8 36 ff ff ff       	call   801294 <nsipc>
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801371:	8b 45 0c             	mov    0xc(%ebp),%eax
  801374:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801379:	b8 03 00 00 00       	mov    $0x3,%eax
  80137e:	e8 11 ff ff ff       	call   801294 <nsipc>
}
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <nsipc_close>:

int
nsipc_close(int s)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801393:	b8 04 00 00 00       	mov    $0x4,%eax
  801398:	e8 f7 fe ff ff       	call   801294 <nsipc>
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8013b1:	53                   	push   %ebx
  8013b2:	ff 75 0c             	pushl  0xc(%ebp)
  8013b5:	68 04 60 80 00       	push   $0x806004
  8013ba:	e8 4a ef ff ff       	call   800309 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8013bf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8013c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ca:	e8 c5 fe ff ff       	call   801294 <nsipc>
}
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8013ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ef:	e8 a0 fe ff ff       	call   801294 <nsipc>
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
  8013fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801406:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80140c:	8b 45 14             	mov    0x14(%ebp),%eax
  80140f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801414:	b8 07 00 00 00       	mov    $0x7,%eax
  801419:	e8 76 fe ff ff       	call   801294 <nsipc>
  80141e:	89 c3                	mov    %eax,%ebx
  801420:	85 c0                	test   %eax,%eax
  801422:	78 35                	js     801459 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801424:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801429:	7f 04                	jg     80142f <nsipc_recv+0x39>
  80142b:	39 c6                	cmp    %eax,%esi
  80142d:	7d 16                	jge    801445 <nsipc_recv+0x4f>
  80142f:	68 d7 24 80 00       	push   $0x8024d7
  801434:	68 98 24 80 00       	push   $0x802498
  801439:	6a 62                	push   $0x62
  80143b:	68 ec 24 80 00       	push   $0x8024ec
  801440:	e8 84 05 00 00       	call   8019c9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	50                   	push   %eax
  801449:	68 00 60 80 00       	push   $0x806000
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	e8 b3 ee ff ff       	call   800309 <memmove>
  801456:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801459:	89 d8                	mov    %ebx,%eax
  80145b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145e:	5b                   	pop    %ebx
  80145f:	5e                   	pop    %esi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	53                   	push   %ebx
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80146c:	8b 45 08             	mov    0x8(%ebp),%eax
  80146f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801474:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80147a:	7e 16                	jle    801492 <nsipc_send+0x30>
  80147c:	68 f8 24 80 00       	push   $0x8024f8
  801481:	68 98 24 80 00       	push   $0x802498
  801486:	6a 6d                	push   $0x6d
  801488:	68 ec 24 80 00       	push   $0x8024ec
  80148d:	e8 37 05 00 00       	call   8019c9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	53                   	push   %ebx
  801496:	ff 75 0c             	pushl  0xc(%ebp)
  801499:	68 0c 60 80 00       	push   $0x80600c
  80149e:	e8 66 ee ff ff       	call   800309 <memmove>
	nsipcbuf.send.req_size = size;
  8014a3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8014b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8014b6:	e8 d9 fd ff ff       	call   801294 <nsipc>
}
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8014d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8014de:	b8 09 00 00 00       	mov    $0x9,%eax
  8014e3:	e8 ac fd ff ff       	call   801294 <nsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	ff 75 08             	pushl  0x8(%ebp)
  8014f8:	e8 62 f3 ff ff       	call   80085f <fd2data>
  8014fd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	68 04 25 80 00       	push   $0x802504
  801507:	53                   	push   %ebx
  801508:	e8 6a ec ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80150d:	8b 46 04             	mov    0x4(%esi),%eax
  801510:	2b 06                	sub    (%esi),%eax
  801512:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801518:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80151f:	00 00 00 
	stat->st_dev = &devpipe;
  801522:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801529:	30 80 00 
	return 0;
}
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801542:	53                   	push   %ebx
  801543:	6a 00                	push   $0x0
  801545:	e8 b5 f0 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80154a:	89 1c 24             	mov    %ebx,(%esp)
  80154d:	e8 0d f3 ff ff       	call   80085f <fd2data>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	50                   	push   %eax
  801556:	6a 00                	push   $0x0
  801558:	e8 a2 f0 ff ff       	call   8005ff <sys_page_unmap>
}
  80155d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	57                   	push   %edi
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	83 ec 1c             	sub    $0x1c,%esp
  80156b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80156e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801570:	a1 08 40 80 00       	mov    0x804008,%eax
  801575:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	ff 75 e0             	pushl  -0x20(%ebp)
  80157e:	e8 61 0b 00 00       	call   8020e4 <pageref>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	89 3c 24             	mov    %edi,(%esp)
  801588:	e8 57 0b 00 00       	call   8020e4 <pageref>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	39 c3                	cmp    %eax,%ebx
  801592:	0f 94 c1             	sete   %cl
  801595:	0f b6 c9             	movzbl %cl,%ecx
  801598:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80159b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015a1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a4:	39 ce                	cmp    %ecx,%esi
  8015a6:	74 1b                	je     8015c3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015a8:	39 c3                	cmp    %eax,%ebx
  8015aa:	75 c4                	jne    801570 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015ac:	8b 42 58             	mov    0x58(%edx),%eax
  8015af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015b2:	50                   	push   %eax
  8015b3:	56                   	push   %esi
  8015b4:	68 0b 25 80 00       	push   $0x80250b
  8015b9:	e8 e4 04 00 00       	call   801aa2 <cprintf>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	eb ad                	jmp    801570 <_pipeisclosed+0xe>
	}
}
  8015c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5e                   	pop    %esi
  8015cb:	5f                   	pop    %edi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 28             	sub    $0x28,%esp
  8015d7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015da:	56                   	push   %esi
  8015db:	e8 7f f2 ff ff       	call   80085f <fd2data>
  8015e0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8015ea:	eb 4b                	jmp    801637 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015ec:	89 da                	mov    %ebx,%edx
  8015ee:	89 f0                	mov    %esi,%eax
  8015f0:	e8 6d ff ff ff       	call   801562 <_pipeisclosed>
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	75 48                	jne    801641 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015f9:	e8 5d ef ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015fe:	8b 43 04             	mov    0x4(%ebx),%eax
  801601:	8b 0b                	mov    (%ebx),%ecx
  801603:	8d 51 20             	lea    0x20(%ecx),%edx
  801606:	39 d0                	cmp    %edx,%eax
  801608:	73 e2                	jae    8015ec <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80160a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801611:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801614:	89 c2                	mov    %eax,%edx
  801616:	c1 fa 1f             	sar    $0x1f,%edx
  801619:	89 d1                	mov    %edx,%ecx
  80161b:	c1 e9 1b             	shr    $0x1b,%ecx
  80161e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801621:	83 e2 1f             	and    $0x1f,%edx
  801624:	29 ca                	sub    %ecx,%edx
  801626:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80162a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80162e:	83 c0 01             	add    $0x1,%eax
  801631:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801634:	83 c7 01             	add    $0x1,%edi
  801637:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80163a:	75 c2                	jne    8015fe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80163c:	8b 45 10             	mov    0x10(%ebp),%eax
  80163f:	eb 05                	jmp    801646 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 18             	sub    $0x18,%esp
  801657:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80165a:	57                   	push   %edi
  80165b:	e8 ff f1 ff ff       	call   80085f <fd2data>
  801660:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166a:	eb 3d                	jmp    8016a9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80166c:	85 db                	test   %ebx,%ebx
  80166e:	74 04                	je     801674 <devpipe_read+0x26>
				return i;
  801670:	89 d8                	mov    %ebx,%eax
  801672:	eb 44                	jmp    8016b8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801674:	89 f2                	mov    %esi,%edx
  801676:	89 f8                	mov    %edi,%eax
  801678:	e8 e5 fe ff ff       	call   801562 <_pipeisclosed>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	75 32                	jne    8016b3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801681:	e8 d5 ee ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801686:	8b 06                	mov    (%esi),%eax
  801688:	3b 46 04             	cmp    0x4(%esi),%eax
  80168b:	74 df                	je     80166c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80168d:	99                   	cltd   
  80168e:	c1 ea 1b             	shr    $0x1b,%edx
  801691:	01 d0                	add    %edx,%eax
  801693:	83 e0 1f             	and    $0x1f,%eax
  801696:	29 d0                	sub    %edx,%eax
  801698:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80169d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016a3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a6:	83 c3 01             	add    $0x1,%ebx
  8016a9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016ac:	75 d8                	jne    801686 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b1:	eb 05                	jmp    8016b8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	e8 a5 f1 ff ff       	call   800876 <fd_alloc>
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	0f 88 2c 01 00 00    	js     80180a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016de:	83 ec 04             	sub    $0x4,%esp
  8016e1:	68 07 04 00 00       	push   $0x407
  8016e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 8a ee ff ff       	call   80057a <sys_page_alloc>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 c2                	mov    %eax,%edx
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	0f 88 0d 01 00 00    	js     80180a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016fd:	83 ec 0c             	sub    $0xc,%esp
  801700:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	e8 6d f1 ff ff       	call   800876 <fd_alloc>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	0f 88 e2 00 00 00    	js     8017f8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	68 07 04 00 00       	push   $0x407
  80171e:	ff 75 f0             	pushl  -0x10(%ebp)
  801721:	6a 00                	push   $0x0
  801723:	e8 52 ee ff ff       	call   80057a <sys_page_alloc>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	0f 88 c3 00 00 00    	js     8017f8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	ff 75 f4             	pushl  -0xc(%ebp)
  80173b:	e8 1f f1 ff ff       	call   80085f <fd2data>
  801740:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801742:	83 c4 0c             	add    $0xc,%esp
  801745:	68 07 04 00 00       	push   $0x407
  80174a:	50                   	push   %eax
  80174b:	6a 00                	push   $0x0
  80174d:	e8 28 ee ff ff       	call   80057a <sys_page_alloc>
  801752:	89 c3                	mov    %eax,%ebx
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	0f 88 89 00 00 00    	js     8017e8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175f:	83 ec 0c             	sub    $0xc,%esp
  801762:	ff 75 f0             	pushl  -0x10(%ebp)
  801765:	e8 f5 f0 ff ff       	call   80085f <fd2data>
  80176a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801771:	50                   	push   %eax
  801772:	6a 00                	push   $0x0
  801774:	56                   	push   %esi
  801775:	6a 00                	push   $0x0
  801777:	e8 41 ee ff ff       	call   8005bd <sys_page_map>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 20             	add    $0x20,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 55                	js     8017da <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801785:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801793:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80179a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b5:	e8 95 f0 ff ff       	call   80084f <fd2num>
  8017ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017bf:	83 c4 04             	add    $0x4,%esp
  8017c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c5:	e8 85 f0 ff ff       	call   80084f <fd2num>
  8017ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	eb 30                	jmp    80180a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	56                   	push   %esi
  8017de:	6a 00                	push   $0x0
  8017e0:	e8 1a ee ff ff       	call   8005ff <sys_page_unmap>
  8017e5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 0a ee ff ff       	call   8005ff <sys_page_unmap>
  8017f5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fe:	6a 00                	push   $0x0
  801800:	e8 fa ed ff ff       	call   8005ff <sys_page_unmap>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80180a:	89 d0                	mov    %edx,%eax
  80180c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	ff 75 08             	pushl  0x8(%ebp)
  801820:	e8 a0 f0 ff ff       	call   8008c5 <fd_lookup>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 18                	js     801844 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	ff 75 f4             	pushl  -0xc(%ebp)
  801832:	e8 28 f0 ff ff       	call   80085f <fd2data>
	return _pipeisclosed(fd, p);
  801837:	89 c2                	mov    %eax,%edx
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	e8 21 fd ff ff       	call   801562 <_pipeisclosed>
  801841:	83 c4 10             	add    $0x10,%esp
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801849:	b8 00 00 00 00       	mov    $0x0,%eax
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801856:	68 23 25 80 00       	push   $0x802523
  80185b:	ff 75 0c             	pushl  0xc(%ebp)
  80185e:	e8 14 e9 ff ff       	call   800177 <strcpy>
	return 0;
}
  801863:	b8 00 00 00 00       	mov    $0x0,%eax
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801876:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80187b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801881:	eb 2d                	jmp    8018b0 <devcons_write+0x46>
		m = n - tot;
  801883:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801886:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801888:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80188b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801890:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801893:	83 ec 04             	sub    $0x4,%esp
  801896:	53                   	push   %ebx
  801897:	03 45 0c             	add    0xc(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	57                   	push   %edi
  80189c:	e8 68 ea ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  8018a1:	83 c4 08             	add    $0x8,%esp
  8018a4:	53                   	push   %ebx
  8018a5:	57                   	push   %edi
  8018a6:	e8 13 ec ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ab:	01 de                	add    %ebx,%esi
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	89 f0                	mov    %esi,%eax
  8018b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b5:	72 cc                	jb     801883 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ce:	74 2a                	je     8018fa <devcons_read+0x3b>
  8018d0:	eb 05                	jmp    8018d7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018d2:	e8 84 ec ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018d7:	e8 00 ec ff ff       	call   8004dc <sys_cgetc>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	74 f2                	je     8018d2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 16                	js     8018fa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018e4:	83 f8 04             	cmp    $0x4,%eax
  8018e7:	74 0c                	je     8018f5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ec:	88 02                	mov    %al,(%edx)
	return 1;
  8018ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f3:	eb 05                	jmp    8018fa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801908:	6a 01                	push   $0x1
  80190a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80190d:	50                   	push   %eax
  80190e:	e8 ab eb ff ff       	call   8004be <sys_cputs>
}
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <getchar>:

int
getchar(void)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80191e:	6a 01                	push   $0x1
  801920:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801923:	50                   	push   %eax
  801924:	6a 00                	push   $0x0
  801926:	e8 00 f2 ff ff       	call   800b2b <read>
	if (r < 0)
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 0f                	js     801941 <getchar+0x29>
		return r;
	if (r < 1)
  801932:	85 c0                	test   %eax,%eax
  801934:	7e 06                	jle    80193c <getchar+0x24>
		return -E_EOF;
	return c;
  801936:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80193a:	eb 05                	jmp    801941 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80193c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194c:	50                   	push   %eax
  80194d:	ff 75 08             	pushl  0x8(%ebp)
  801950:	e8 70 ef ff ff       	call   8008c5 <fd_lookup>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 11                	js     80196d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80195c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801965:	39 10                	cmp    %edx,(%eax)
  801967:	0f 94 c0             	sete   %al
  80196a:	0f b6 c0             	movzbl %al,%eax
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <opencons>:

int
opencons(void)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801975:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	e8 f8 ee ff ff       	call   800876 <fd_alloc>
  80197e:	83 c4 10             	add    $0x10,%esp
		return r;
  801981:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801983:	85 c0                	test   %eax,%eax
  801985:	78 3e                	js     8019c5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801987:	83 ec 04             	sub    $0x4,%esp
  80198a:	68 07 04 00 00       	push   $0x407
  80198f:	ff 75 f4             	pushl  -0xc(%ebp)
  801992:	6a 00                	push   $0x0
  801994:	e8 e1 eb ff ff       	call   80057a <sys_page_alloc>
  801999:	83 c4 10             	add    $0x10,%esp
		return r;
  80199c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 23                	js     8019c5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019a2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	50                   	push   %eax
  8019bb:	e8 8f ee ff ff       	call   80084f <fd2num>
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	83 c4 10             	add    $0x10,%esp
}
  8019c5:	89 d0                	mov    %edx,%eax
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019d7:	e8 60 eb ff ff       	call   80053c <sys_getenvid>
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	ff 75 08             	pushl  0x8(%ebp)
  8019e5:	56                   	push   %esi
  8019e6:	50                   	push   %eax
  8019e7:	68 30 25 80 00       	push   $0x802530
  8019ec:	e8 b1 00 00 00       	call   801aa2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019f1:	83 c4 18             	add    $0x18,%esp
  8019f4:	53                   	push   %ebx
  8019f5:	ff 75 10             	pushl  0x10(%ebp)
  8019f8:	e8 54 00 00 00       	call   801a51 <vcprintf>
	cprintf("\n");
  8019fd:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  801a04:	e8 99 00 00 00       	call   801aa2 <cprintf>
  801a09:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a0c:	cc                   	int3   
  801a0d:	eb fd                	jmp    801a0c <_panic+0x43>

00801a0f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 04             	sub    $0x4,%esp
  801a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801a19:	8b 13                	mov    (%ebx),%edx
  801a1b:	8d 42 01             	lea    0x1(%edx),%eax
  801a1e:	89 03                	mov    %eax,(%ebx)
  801a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a23:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a27:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a2c:	75 1a                	jne    801a48 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	68 ff 00 00 00       	push   $0xff
  801a36:	8d 43 08             	lea    0x8(%ebx),%eax
  801a39:	50                   	push   %eax
  801a3a:	e8 7f ea ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  801a3f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a45:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a48:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a5a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a61:	00 00 00 
	b.cnt = 0;
  801a64:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a6b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	ff 75 08             	pushl  0x8(%ebp)
  801a74:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	68 0f 1a 80 00       	push   $0x801a0f
  801a80:	e8 54 01 00 00       	call   801bd9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a85:	83 c4 08             	add    $0x8,%esp
  801a88:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a8e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	e8 24 ea ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  801a9a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aa8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801aab:	50                   	push   %eax
  801aac:	ff 75 08             	pushl  0x8(%ebp)
  801aaf:	e8 9d ff ff ff       	call   801a51 <vcprintf>
	va_end(ap);

	return cnt;
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 1c             	sub    $0x1c,%esp
  801abf:	89 c7                	mov    %eax,%edi
  801ac1:	89 d6                	mov    %edx,%esi
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801acc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801ada:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801add:	39 d3                	cmp    %edx,%ebx
  801adf:	72 05                	jb     801ae6 <printnum+0x30>
  801ae1:	39 45 10             	cmp    %eax,0x10(%ebp)
  801ae4:	77 45                	ja     801b2b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	ff 75 18             	pushl  0x18(%ebp)
  801aec:	8b 45 14             	mov    0x14(%ebp),%eax
  801aef:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801af2:	53                   	push   %ebx
  801af3:	ff 75 10             	pushl  0x10(%ebp)
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afc:	ff 75 e0             	pushl  -0x20(%ebp)
  801aff:	ff 75 dc             	pushl  -0x24(%ebp)
  801b02:	ff 75 d8             	pushl  -0x28(%ebp)
  801b05:	e8 16 06 00 00       	call   802120 <__udivdi3>
  801b0a:	83 c4 18             	add    $0x18,%esp
  801b0d:	52                   	push   %edx
  801b0e:	50                   	push   %eax
  801b0f:	89 f2                	mov    %esi,%edx
  801b11:	89 f8                	mov    %edi,%eax
  801b13:	e8 9e ff ff ff       	call   801ab6 <printnum>
  801b18:	83 c4 20             	add    $0x20,%esp
  801b1b:	eb 18                	jmp    801b35 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	56                   	push   %esi
  801b21:	ff 75 18             	pushl  0x18(%ebp)
  801b24:	ff d7                	call   *%edi
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	eb 03                	jmp    801b2e <printnum+0x78>
  801b2b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b2e:	83 eb 01             	sub    $0x1,%ebx
  801b31:	85 db                	test   %ebx,%ebx
  801b33:	7f e8                	jg     801b1d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	56                   	push   %esi
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b42:	ff 75 dc             	pushl  -0x24(%ebp)
  801b45:	ff 75 d8             	pushl  -0x28(%ebp)
  801b48:	e8 03 07 00 00       	call   802250 <__umoddi3>
  801b4d:	83 c4 14             	add    $0x14,%esp
  801b50:	0f be 80 53 25 80 00 	movsbl 0x802553(%eax),%eax
  801b57:	50                   	push   %eax
  801b58:	ff d7                	call   *%edi
}
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b68:	83 fa 01             	cmp    $0x1,%edx
  801b6b:	7e 0e                	jle    801b7b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b6d:	8b 10                	mov    (%eax),%edx
  801b6f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b72:	89 08                	mov    %ecx,(%eax)
  801b74:	8b 02                	mov    (%edx),%eax
  801b76:	8b 52 04             	mov    0x4(%edx),%edx
  801b79:	eb 22                	jmp    801b9d <getuint+0x38>
	else if (lflag)
  801b7b:	85 d2                	test   %edx,%edx
  801b7d:	74 10                	je     801b8f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b7f:	8b 10                	mov    (%eax),%edx
  801b81:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b84:	89 08                	mov    %ecx,(%eax)
  801b86:	8b 02                	mov    (%edx),%eax
  801b88:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8d:	eb 0e                	jmp    801b9d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b8f:	8b 10                	mov    (%eax),%edx
  801b91:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b94:	89 08                	mov    %ecx,(%eax)
  801b96:	8b 02                	mov    (%edx),%eax
  801b98:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ba5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ba9:	8b 10                	mov    (%eax),%edx
  801bab:	3b 50 04             	cmp    0x4(%eax),%edx
  801bae:	73 0a                	jae    801bba <sprintputch+0x1b>
		*b->buf++ = ch;
  801bb0:	8d 4a 01             	lea    0x1(%edx),%ecx
  801bb3:	89 08                	mov    %ecx,(%eax)
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	88 02                	mov    %al,(%edx)
}
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801bc2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801bc5:	50                   	push   %eax
  801bc6:	ff 75 10             	pushl  0x10(%ebp)
  801bc9:	ff 75 0c             	pushl  0xc(%ebp)
  801bcc:	ff 75 08             	pushl  0x8(%ebp)
  801bcf:	e8 05 00 00 00       	call   801bd9 <vprintfmt>
	va_end(ap);
}
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	57                   	push   %edi
  801bdd:	56                   	push   %esi
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 2c             	sub    $0x2c,%esp
  801be2:	8b 75 08             	mov    0x8(%ebp),%esi
  801be5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801be8:	8b 7d 10             	mov    0x10(%ebp),%edi
  801beb:	eb 12                	jmp    801bff <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 84 89 03 00 00    	je     801f7e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bf5:	83 ec 08             	sub    $0x8,%esp
  801bf8:	53                   	push   %ebx
  801bf9:	50                   	push   %eax
  801bfa:	ff d6                	call   *%esi
  801bfc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bff:	83 c7 01             	add    $0x1,%edi
  801c02:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801c06:	83 f8 25             	cmp    $0x25,%eax
  801c09:	75 e2                	jne    801bed <vprintfmt+0x14>
  801c0b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801c0f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801c16:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c1d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx
  801c29:	eb 07                	jmp    801c32 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c2e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c32:	8d 47 01             	lea    0x1(%edi),%eax
  801c35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c38:	0f b6 07             	movzbl (%edi),%eax
  801c3b:	0f b6 c8             	movzbl %al,%ecx
  801c3e:	83 e8 23             	sub    $0x23,%eax
  801c41:	3c 55                	cmp    $0x55,%al
  801c43:	0f 87 1a 03 00 00    	ja     801f63 <vprintfmt+0x38a>
  801c49:	0f b6 c0             	movzbl %al,%eax
  801c4c:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  801c53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c56:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c5a:	eb d6                	jmp    801c32 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c67:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c6a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c6e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c71:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c74:	83 fa 09             	cmp    $0x9,%edx
  801c77:	77 39                	ja     801cb2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c79:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c7c:	eb e9                	jmp    801c67 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c81:	8d 48 04             	lea    0x4(%eax),%ecx
  801c84:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c87:	8b 00                	mov    (%eax),%eax
  801c89:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c8f:	eb 27                	jmp    801cb8 <vprintfmt+0xdf>
  801c91:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c94:	85 c0                	test   %eax,%eax
  801c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c9b:	0f 49 c8             	cmovns %eax,%ecx
  801c9e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ca1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ca4:	eb 8c                	jmp    801c32 <vprintfmt+0x59>
  801ca6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ca9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801cb0:	eb 80                	jmp    801c32 <vprintfmt+0x59>
  801cb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cb5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801cb8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cbc:	0f 89 70 ff ff ff    	jns    801c32 <vprintfmt+0x59>
				width = precision, precision = -1;
  801cc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cc8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ccf:	e9 5e ff ff ff       	jmp    801c32 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801cd4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cda:	e9 53 ff ff ff       	jmp    801c32 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801cdf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce2:	8d 50 04             	lea    0x4(%eax),%edx
  801ce5:	89 55 14             	mov    %edx,0x14(%ebp)
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	53                   	push   %ebx
  801cec:	ff 30                	pushl  (%eax)
  801cee:	ff d6                	call   *%esi
			break;
  801cf0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cf3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cf6:	e9 04 ff ff ff       	jmp    801bff <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cfb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfe:	8d 50 04             	lea    0x4(%eax),%edx
  801d01:	89 55 14             	mov    %edx,0x14(%ebp)
  801d04:	8b 00                	mov    (%eax),%eax
  801d06:	99                   	cltd   
  801d07:	31 d0                	xor    %edx,%eax
  801d09:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801d0b:	83 f8 0f             	cmp    $0xf,%eax
  801d0e:	7f 0b                	jg     801d1b <vprintfmt+0x142>
  801d10:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  801d17:	85 d2                	test   %edx,%edx
  801d19:	75 18                	jne    801d33 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801d1b:	50                   	push   %eax
  801d1c:	68 6b 25 80 00       	push   $0x80256b
  801d21:	53                   	push   %ebx
  801d22:	56                   	push   %esi
  801d23:	e8 94 fe ff ff       	call   801bbc <printfmt>
  801d28:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d2e:	e9 cc fe ff ff       	jmp    801bff <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d33:	52                   	push   %edx
  801d34:	68 aa 24 80 00       	push   $0x8024aa
  801d39:	53                   	push   %ebx
  801d3a:	56                   	push   %esi
  801d3b:	e8 7c fe ff ff       	call   801bbc <printfmt>
  801d40:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d46:	e9 b4 fe ff ff       	jmp    801bff <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4e:	8d 50 04             	lea    0x4(%eax),%edx
  801d51:	89 55 14             	mov    %edx,0x14(%ebp)
  801d54:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d56:	85 ff                	test   %edi,%edi
  801d58:	b8 64 25 80 00       	mov    $0x802564,%eax
  801d5d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d64:	0f 8e 94 00 00 00    	jle    801dfe <vprintfmt+0x225>
  801d6a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d6e:	0f 84 98 00 00 00    	je     801e0c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	ff 75 d0             	pushl  -0x30(%ebp)
  801d7a:	57                   	push   %edi
  801d7b:	e8 d6 e3 ff ff       	call   800156 <strnlen>
  801d80:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d83:	29 c1                	sub    %eax,%ecx
  801d85:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d88:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d8b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d92:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d95:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d97:	eb 0f                	jmp    801da8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d99:	83 ec 08             	sub    $0x8,%esp
  801d9c:	53                   	push   %ebx
  801d9d:	ff 75 e0             	pushl  -0x20(%ebp)
  801da0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801da2:	83 ef 01             	sub    $0x1,%edi
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	85 ff                	test   %edi,%edi
  801daa:	7f ed                	jg     801d99 <vprintfmt+0x1c0>
  801dac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801daf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801db2:	85 c9                	test   %ecx,%ecx
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
  801db9:	0f 49 c1             	cmovns %ecx,%eax
  801dbc:	29 c1                	sub    %eax,%ecx
  801dbe:	89 75 08             	mov    %esi,0x8(%ebp)
  801dc1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dc4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc7:	89 cb                	mov    %ecx,%ebx
  801dc9:	eb 4d                	jmp    801e18 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801dcb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801dcf:	74 1b                	je     801dec <vprintfmt+0x213>
  801dd1:	0f be c0             	movsbl %al,%eax
  801dd4:	83 e8 20             	sub    $0x20,%eax
  801dd7:	83 f8 5e             	cmp    $0x5e,%eax
  801dda:	76 10                	jbe    801dec <vprintfmt+0x213>
					putch('?', putdat);
  801ddc:	83 ec 08             	sub    $0x8,%esp
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	6a 3f                	push   $0x3f
  801de4:	ff 55 08             	call   *0x8(%ebp)
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	eb 0d                	jmp    801df9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801dec:	83 ec 08             	sub    $0x8,%esp
  801def:	ff 75 0c             	pushl  0xc(%ebp)
  801df2:	52                   	push   %edx
  801df3:	ff 55 08             	call   *0x8(%ebp)
  801df6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801df9:	83 eb 01             	sub    $0x1,%ebx
  801dfc:	eb 1a                	jmp    801e18 <vprintfmt+0x23f>
  801dfe:	89 75 08             	mov    %esi,0x8(%ebp)
  801e01:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e04:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e0a:	eb 0c                	jmp    801e18 <vprintfmt+0x23f>
  801e0c:	89 75 08             	mov    %esi,0x8(%ebp)
  801e0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e18:	83 c7 01             	add    $0x1,%edi
  801e1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801e1f:	0f be d0             	movsbl %al,%edx
  801e22:	85 d2                	test   %edx,%edx
  801e24:	74 23                	je     801e49 <vprintfmt+0x270>
  801e26:	85 f6                	test   %esi,%esi
  801e28:	78 a1                	js     801dcb <vprintfmt+0x1f2>
  801e2a:	83 ee 01             	sub    $0x1,%esi
  801e2d:	79 9c                	jns    801dcb <vprintfmt+0x1f2>
  801e2f:	89 df                	mov    %ebx,%edi
  801e31:	8b 75 08             	mov    0x8(%ebp),%esi
  801e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e37:	eb 18                	jmp    801e51 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e39:	83 ec 08             	sub    $0x8,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	6a 20                	push   $0x20
  801e3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e41:	83 ef 01             	sub    $0x1,%edi
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	eb 08                	jmp    801e51 <vprintfmt+0x278>
  801e49:	89 df                	mov    %ebx,%edi
  801e4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801e4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e51:	85 ff                	test   %edi,%edi
  801e53:	7f e4                	jg     801e39 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e58:	e9 a2 fd ff ff       	jmp    801bff <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e5d:	83 fa 01             	cmp    $0x1,%edx
  801e60:	7e 16                	jle    801e78 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e62:	8b 45 14             	mov    0x14(%ebp),%eax
  801e65:	8d 50 08             	lea    0x8(%eax),%edx
  801e68:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6b:	8b 50 04             	mov    0x4(%eax),%edx
  801e6e:	8b 00                	mov    (%eax),%eax
  801e70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e73:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e76:	eb 32                	jmp    801eaa <vprintfmt+0x2d1>
	else if (lflag)
  801e78:	85 d2                	test   %edx,%edx
  801e7a:	74 18                	je     801e94 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e7c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7f:	8d 50 04             	lea    0x4(%eax),%edx
  801e82:	89 55 14             	mov    %edx,0x14(%ebp)
  801e85:	8b 00                	mov    (%eax),%eax
  801e87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e8a:	89 c1                	mov    %eax,%ecx
  801e8c:	c1 f9 1f             	sar    $0x1f,%ecx
  801e8f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e92:	eb 16                	jmp    801eaa <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e94:	8b 45 14             	mov    0x14(%ebp),%eax
  801e97:	8d 50 04             	lea    0x4(%eax),%edx
  801e9a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e9d:	8b 00                	mov    (%eax),%eax
  801e9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ea2:	89 c1                	mov    %eax,%ecx
  801ea4:	c1 f9 1f             	sar    $0x1f,%ecx
  801ea7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801eaa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ead:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801eb0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801eb5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801eb9:	79 74                	jns    801f2f <vprintfmt+0x356>
				putch('-', putdat);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	6a 2d                	push   $0x2d
  801ec1:	ff d6                	call   *%esi
				num = -(long long) num;
  801ec3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ec6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ec9:	f7 d8                	neg    %eax
  801ecb:	83 d2 00             	adc    $0x0,%edx
  801ece:	f7 da                	neg    %edx
  801ed0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ed3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ed8:	eb 55                	jmp    801f2f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801eda:	8d 45 14             	lea    0x14(%ebp),%eax
  801edd:	e8 83 fc ff ff       	call   801b65 <getuint>
			base = 10;
  801ee2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ee7:	eb 46                	jmp    801f2f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ee9:	8d 45 14             	lea    0x14(%ebp),%eax
  801eec:	e8 74 fc ff ff       	call   801b65 <getuint>
                        base = 8;
  801ef1:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ef6:	eb 37                	jmp    801f2f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ef8:	83 ec 08             	sub    $0x8,%esp
  801efb:	53                   	push   %ebx
  801efc:	6a 30                	push   $0x30
  801efe:	ff d6                	call   *%esi
			putch('x', putdat);
  801f00:	83 c4 08             	add    $0x8,%esp
  801f03:	53                   	push   %ebx
  801f04:	6a 78                	push   $0x78
  801f06:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801f08:	8b 45 14             	mov    0x14(%ebp),%eax
  801f0b:	8d 50 04             	lea    0x4(%eax),%edx
  801f0e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801f11:	8b 00                	mov    (%eax),%eax
  801f13:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801f18:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801f1b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801f20:	eb 0d                	jmp    801f2f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f22:	8d 45 14             	lea    0x14(%ebp),%eax
  801f25:	e8 3b fc ff ff       	call   801b65 <getuint>
			base = 16;
  801f2a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f36:	57                   	push   %edi
  801f37:	ff 75 e0             	pushl  -0x20(%ebp)
  801f3a:	51                   	push   %ecx
  801f3b:	52                   	push   %edx
  801f3c:	50                   	push   %eax
  801f3d:	89 da                	mov    %ebx,%edx
  801f3f:	89 f0                	mov    %esi,%eax
  801f41:	e8 70 fb ff ff       	call   801ab6 <printnum>
			break;
  801f46:	83 c4 20             	add    $0x20,%esp
  801f49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f4c:	e9 ae fc ff ff       	jmp    801bff <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	53                   	push   %ebx
  801f55:	51                   	push   %ecx
  801f56:	ff d6                	call   *%esi
			break;
  801f58:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f5e:	e9 9c fc ff ff       	jmp    801bff <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f63:	83 ec 08             	sub    $0x8,%esp
  801f66:	53                   	push   %ebx
  801f67:	6a 25                	push   $0x25
  801f69:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	eb 03                	jmp    801f73 <vprintfmt+0x39a>
  801f70:	83 ef 01             	sub    $0x1,%edi
  801f73:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f77:	75 f7                	jne    801f70 <vprintfmt+0x397>
  801f79:	e9 81 fc ff ff       	jmp    801bff <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 18             	sub    $0x18,%esp
  801f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f95:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f99:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	74 26                	je     801fcd <vsnprintf+0x47>
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	7e 22                	jle    801fcd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fab:	ff 75 14             	pushl  0x14(%ebp)
  801fae:	ff 75 10             	pushl  0x10(%ebp)
  801fb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	68 9f 1b 80 00       	push   $0x801b9f
  801fba:	e8 1a fc ff ff       	call   801bd9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fc2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	eb 05                	jmp    801fd2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fd2:	c9                   	leave  
  801fd3:	c3                   	ret    

00801fd4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fda:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fdd:	50                   	push   %eax
  801fde:	ff 75 10             	pushl  0x10(%ebp)
  801fe1:	ff 75 0c             	pushl  0xc(%ebp)
  801fe4:	ff 75 08             	pushl  0x8(%ebp)
  801fe7:	e8 9a ff ff ff       	call   801f86 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	56                   	push   %esi
  801ff2:	53                   	push   %ebx
  801ff3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ffc:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ffe:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802003:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802006:	83 ec 0c             	sub    $0xc,%esp
  802009:	50                   	push   %eax
  80200a:	e8 1b e7 ff ff       	call   80072a <sys_ipc_recv>

	if (r < 0) {
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	79 16                	jns    80202c <ipc_recv+0x3e>
		if (from_env_store)
  802016:	85 f6                	test   %esi,%esi
  802018:	74 06                	je     802020 <ipc_recv+0x32>
			*from_env_store = 0;
  80201a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802020:	85 db                	test   %ebx,%ebx
  802022:	74 2c                	je     802050 <ipc_recv+0x62>
			*perm_store = 0;
  802024:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80202a:	eb 24                	jmp    802050 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80202c:	85 f6                	test   %esi,%esi
  80202e:	74 0a                	je     80203a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802030:	a1 08 40 80 00       	mov    0x804008,%eax
  802035:	8b 40 74             	mov    0x74(%eax),%eax
  802038:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80203a:	85 db                	test   %ebx,%ebx
  80203c:	74 0a                	je     802048 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80203e:	a1 08 40 80 00       	mov    0x804008,%eax
  802043:	8b 40 78             	mov    0x78(%eax),%eax
  802046:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802048:	a1 08 40 80 00       	mov    0x804008,%eax
  80204d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802050:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5d                   	pop    %ebp
  802056:	c3                   	ret    

00802057 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	57                   	push   %edi
  80205b:	56                   	push   %esi
  80205c:	53                   	push   %ebx
  80205d:	83 ec 0c             	sub    $0xc,%esp
  802060:	8b 7d 08             	mov    0x8(%ebp),%edi
  802063:	8b 75 0c             	mov    0xc(%ebp),%esi
  802066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802069:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80206b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802070:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802073:	ff 75 14             	pushl  0x14(%ebp)
  802076:	53                   	push   %ebx
  802077:	56                   	push   %esi
  802078:	57                   	push   %edi
  802079:	e8 89 e6 ff ff       	call   800707 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80207e:	83 c4 10             	add    $0x10,%esp
  802081:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802084:	75 07                	jne    80208d <ipc_send+0x36>
			sys_yield();
  802086:	e8 d0 e4 ff ff       	call   80055b <sys_yield>
  80208b:	eb e6                	jmp    802073 <ipc_send+0x1c>
		} else if (r < 0) {
  80208d:	85 c0                	test   %eax,%eax
  80208f:	79 12                	jns    8020a3 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802091:	50                   	push   %eax
  802092:	68 60 28 80 00       	push   $0x802860
  802097:	6a 51                	push   $0x51
  802099:	68 6d 28 80 00       	push   $0x80286d
  80209e:	e8 26 f9 ff ff       	call   8019c9 <_panic>
		}
	}
}
  8020a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a6:	5b                   	pop    %ebx
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020bf:	8b 52 50             	mov    0x50(%edx),%edx
  8020c2:	39 ca                	cmp    %ecx,%edx
  8020c4:	75 0d                	jne    8020d3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ce:	8b 40 48             	mov    0x48(%eax),%eax
  8020d1:	eb 0f                	jmp    8020e2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d3:	83 c0 01             	add    $0x1,%eax
  8020d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020db:	75 d9                	jne    8020b6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	c1 e8 16             	shr    $0x16,%eax
  8020ef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fb:	f6 c1 01             	test   $0x1,%cl
  8020fe:	74 1d                	je     80211d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802100:	c1 ea 0c             	shr    $0xc,%edx
  802103:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80210a:	f6 c2 01             	test   $0x1,%dl
  80210d:	74 0e                	je     80211d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210f:	c1 ea 0c             	shr    $0xc,%edx
  802112:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802119:	ef 
  80211a:	0f b7 c0             	movzwl %ax,%eax
}
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
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
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
