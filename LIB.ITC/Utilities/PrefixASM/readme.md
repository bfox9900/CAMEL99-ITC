# Prefix Assembler Extensions

The prefixasmRAM.fth file provides a layer that lives on top of the
Forth style RPN Assembler, DSK1.ASM9900.  Function is not improved in
any way, but the syntax is more conventional compared to the TI-99
Assembler.  Some users may like it better.

There are still Camel99isms in the syntax however. Their are still two kinds of labels.

The L: label creator returns an address that can be used for instructions that branch within the entire memory space. ( BL BLWP LWPI etc.)

See WORKSPACES.FTH for some examples using L:

The numbered labels ( $  $: )  are used by the JMP family of instructions
and are limited to +/- 127 bytes. These are typically used to navigate inside
a CODE definition.
