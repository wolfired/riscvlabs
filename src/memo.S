# Global Symbol Directive
# syntax:
#   .global symbol


# Local Symbol Directive
# syntax:
#   .local symbol

# Equate Directive
# syntax:
#   .equ symbol, expression 

# Readonly Data
.section .rodata


# Read-write Data
.section .data


# Read-write Data(uninit)
.section .bss 


# Readonly Code
.section .text

.global _start
_start:
    j _start
























