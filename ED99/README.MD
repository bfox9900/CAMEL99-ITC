# ED99 Multi-file editor

The ED99 editor requires the 1Mbyte SAMS memory card or an equivalent installed
in your TI-99 system. Text files are held in the extended memory and paged into
two 4K windows in low RAM on demand. Having all this memory allows the editor to
hold five 800 line files simultaneously.

The editor uses the traditional key commands commonly used by TI-99 editors but
there are extra commands that require the user to read the manual.

A big difference with ED99 is that it uses the Forth interpreter for some
commands. Operations that may overwrite the file like SAVE and SAVEAS are
performed by typing the commands in the command line.
