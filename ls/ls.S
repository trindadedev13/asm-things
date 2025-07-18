.section .data
    dir:    .asciz "."
    buf:    .skip 4096
    nl:     .asciz "\n"

.section .bss
    fd:     .skip 8

.section .text
    .global _start

_start:
    mov    x0, #-100      // AT_FDCWD

    // Loads dir to x1
    adrp   x1, dir
    add    x1, x1, :lo12:dir

    mov    x2, #0         // O_READONLY
    mov    x3, 0x0200000  // O_DIRECTORY
    mov    x8, #56        // openat syscall
    svc    #0

    // Loads fd ref to x1
    adrp   x1, fd
    add    x1, x1, :lo12:fd
    // Stores x0 (fd returned from openat) in x0
    str    x0, [x1]

read_loop:
    // getdents64(fd, buf, 4096)

    // Load fd to x0
    adrp   x0, fd
    add    x0, x0, :lo12:fd
    ldr    x0, [x0]

    // Load buf to x1
    adrp   x1, buf
    add    x1, x1, :lo12:buf

    mov    x2, #4096 // size of buf, 4096
    mov    x8, #61   // syscall getdents64
    svc    #0

    // check if bytes write is 0 or negative
    // if yes, so exit
    cmp    x0, #0
    ble    exit

    mov    x20, x0  // store total bytes in x20

    // Load buf to x21
    // x1 = buf
    adrp   x21, buf
    add    x21, x21, :lo12:buf

next_entry:
    // if theses not byte to read, so back to new read
    cmp     x20, 0
    ble     read_loop

    // each entry:
    // struct linux_dirent64 {
    //   ino64_t        d_ino;      // 0
    //   off64_t        d_off;      // 8
    //   unsigned short d_reclen;   // 16
    //   unsigned char  d_type;     // 18
    //   char           d_name[];   // 19
    // }

    ldrh    w22, [x21, #16]   // read d_reclen (size of entry) to w22
    // pointer to d_name
    // char* name = (char*)entry + 19
    add     x23, x21, #19     // pointer to d_name

    mov     x24, x23  // x24 = x23 (name)
    mov     x25, #0   // the name size, init in 0

find_end:
    // read 1 byte in x24 with offset x25 to w26
    ldrb    w26, [x24, x25]

    // if w26 is 0 (NULL) so its end
    cmp     w26, #0
    // print it
    beq     print_name

    // increment offset/size
    add     x25, x25, #1

    // loop
    b       find_end

print_name:
    mov     x0, #1
    mov     x1, x23
    mov     x2, x25
    mov     x8, #64
    svc     0

    mov     x0, #1
    adrp    x1, nl
    add     x1, x1, :lo12:nl
    mov     x2, #1
    svc     #0

    add     x21, x21, x22
    sub     x20, x20, x22
    b       next_entry

exit:
    mov    x0, #0
    mov    x8, #93
    svc    #0