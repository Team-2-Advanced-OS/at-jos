+ ld obj/kern/kernel
+ mk obj/kern/kernel.img

(process:10853): GLib-WARNING **: /build/glib2.0-7IO_Yw/glib2.0-2.48.1/./glib/gmem.c:483: custom memory allocation vtable not supported

(process:10855): GLib-WARNING **: /build/glib2.0-7IO_Yw/glib2.0-2.48.1/./glib/gmem.c:483: custom memory allocation vtable not supported
6828 decimal is x 1, y 3, z 4
15254 octal!
Physical memory: 66556K available, base = 640K, extended = 65532K
boot_alloc memory at f026d000
Next memory at f026e000
boot_alloc memory at f026e000
Next memory at f028f000
npages: 16639
npages_basemem: 160
pages: f026e000
boot_alloc memory at f028f000
Next memory at f02ae000
boot_alloc memory at f02ae000
Next memory at f02ae000
check_page_free_list done
check_page_alloc() succeeded!
so far so good
pp2 f026ffe8
kern_pgdir f026d000
kern_pgdir[0] is 3ff007
Virtual Address ef800000 mapped to Physical Address 0
Virtual Address ef802000 mapped to Physical Address 0
check_page() succeeded!
Virtual Address ef000000 mapped to Physical Address 26e000
PADDR(pages) 26e000
Virtual Address eec00000 mapped to Physical Address 28f000
Virtual Address efff8000 mapped to Physical Address 115000
PADDR(bootstack) 115000
Virtual Address f0000000 mapped to Physical Address 0
kernel panic on CPU 0 at kern/pmap.c:855: assertion failed: check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
qemu: terminating on signal 15 from pid 10769
