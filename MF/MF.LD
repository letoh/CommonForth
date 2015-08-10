SECTIONS {
  .text : { *(.text) ;
            . = ALIGN( 0x1000 ) ;    
          }
  .data : { *(.ctor) *(.dtor) *(.data) ;
            . = ALIGN( 0x1000 ) ;    
          }
  .bss  : { *(.bss) *(COMMON) ;
            . = ABSOLUTE( 0x180000 ) ;
            _MF_SYSTEM_SPACE = . ;
            . = . + 0x80000 + 4096 ;
          }
}
