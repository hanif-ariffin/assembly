#ifndef _MAIN_ASM_H
#define _MAIN_ASM_H


/**
Pretty sure this is the part where we are forcing the compiler to ignore any C++ stuffs and treat this as a C code??
**/
#ifdef __cplusplus
    extern "C" { /* our assembly functions have C calling convention */
#endif

void asm_main(void);
  /* interface to my assembly main function */
void PLL_init(void);

#ifdef __cplusplus
    }
#endif

#endif /* _MAIN_ASM_H */
