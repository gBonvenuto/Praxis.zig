MEMORY {
    flash (rx) : ORIGIN = 0x0, LENGTH = 32K

    /* Começa depois dos registradores */
    ram (rwx) : ORIGIN = 0x100, LENGTH = 2K
}

SECTIONS {
    .text : {
        /* A primeira instrução é o RESET
         Então colocamos a tabela de vetores
         de interrupção no começo */
        KEEP (*(.vectors))

        *(.text)
        *(.rodata)
    } > flash

    /* No binário o .data deve estar ao fim
    da seção .text */
    .data : AT(ADDR(.text)+SIZEOF(.text)) {
        __data_start = .;
        *(.data)
        __data_end = .;
    } > ram
    __data_load_start = LOADADDR(.data);
    .bss (NOLOAD) : {
        __bss_start = .;
        *(.bss)
        __bss_end = .;
        . = ALIGN(4);
        __stack = ORIGIN(ram) + LENGTH(ram);
    } > ram
}
