SECTIONS {
  .text : { *(.text) ;
            . = ALIGN( 0x1000 ) ;    
          }
  .data : { *(.ctor) *(.dtor) *(.data) ;
            . = ALIGN( 0x1000 ) ;    
          }
  .bss  : { *(.bss) *(COMMON) ;
            . = ABSOLUTE( 0x140000 ) ;
            _CF_SYSTEM_SPACE = . ;
            . = . + 0x400000 + 4096 ;
          }
}
