.section .data
    msg:
        .asciz "Aquiles"
    buffer:
        .skip 100 // 100 bytes

.section .text
    .global _start

strlen:
    mov    x2, #0
    
    .loop:
        ldrb    w3, [x1, x2] // read 1 byte of (x1 + x2)

        // compare if w3 is 0 (NULL)
        // if its, so its end, so done.
        cmp     w3, #0
        beq     .done

        // else increment one in size
        add     x2, x2, #1
        b       .loop

    .done:
        ret

_start:
    // x1 = name of file
    // x2 = size of name of file
    ldr     x1, [sp, #16]
    bl      strlen

    // OPEN FILE
    mov     x0, #-100 // dirfd = AT_FDCWD
    mov     x1, x1    // filename = x1
    mov     x2, #0    // flags = O_RDONLY
    mov     x3, #0    // permissions = 0
    mov     x8, #56   // openat syscall
    svc     #0
    mov     x4, x0

    // READ FILE
    mov     x0, x4
    // Loads buffer to x1
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    mov     x2, #100  // Read 100 bytes
    mov     x8, #63   // read syscall
    svc     #0

    // PRINT CONTENT
    mov     x2, x0
    mov     x0, #1
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    mov     x8, #64  // write syscall
    svc     #0

    mov     x0, #0   // status ok
    mov     x8, #93  // exit syscall
    svc     #0