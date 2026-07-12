# Prefix Assembler Extensions

The prefixasmRAM.fth file provides a layer that lives on top of the
Forth style RPN Assembler, DSK1.ASM9900.  Function is not improved, but the syntax is more conventional compared to the TI-99
Assembler.  Some users may like it better.

In this iteration it is still an Assembler to be used within Forth. It should not take to much more effort to make a cross-assember.

The L: label creator returns an address that can be used for instructions that branch within the entire memory space. ( BL BLWP LWPI etc.)

See WORKSPACES.FTH for some examples using BLWP to call sub-programs.

The numbered labels ( $  $: ) are used by the JMP family of instructions
and are limited to +/- 127 bytes. These are typically used to navigate inside a CODE definition.

The assembler has been upgraded so it can handle TI Assembler syntax
for arguments that are HEX numbers and/or symbolic addressing.

Examples:
        MOV R5,@>2004
        MOV @>2004,@>2024
        MOV @>2024,R6
