# On FORTH Coding Style
#### A Discussion

I will admit right up front that I am not an excellent programmer. I am a "good"
programmer. I have encountered many people who have far sharper minds for
complex logic than I ever will. My talent, if I have one, seems to be the
ability to "connect the dots" on the big picture which led to my career being
more at the senior level, creating teams of talented people and helping them see
what really matters for success and allowing them to avoid going down paths that
had no value to the end goal.

That being said I have noticed a trend when competent programmers from "normal"
programming languages begin using Forth. They quickly understand the simple
operators and the branching and looping control words and jump right in.

The results are what I see in the original code for Cosmic Conquest.
That is they write the program in their favourite language, using Forth syntax.

In the case of Cosmic Conquest I going to guess that the original author was a
very good BASIC programmer. We can see that in the following give-aways:

- matrix data is reference by indices rather than my names
- the use of temporary variables to manage data stack shuffling
- long and longer sub-routines
- entire paragraphs of code duplicated in different sub-routines
- no attempt to create a "meta langauge" to make writing a space game simpler
  (Code remains at what I call "raw" Forth level)

Now this is not a crime but it is kind of a shame when the power of the language
is not used.

Here is an example of working code that was written in a style that you might
write in C, contrasted to how it arguably should be written in Forth.

```
  : INKEY ( --- key)
      KEY DUP DUP
      [CHAR] \ >
      IF ( ASCII value 'a' or higher)
          [CHAR] { <
            IF ( ASCII value 'z' or lower)
              223 AND ( mask off upper/lower case bit)
            ENDIF
      ENDIF
      127 AND
      ;
```

Forth style:
```
  HEX
  : ?LOWER  ( c -- ?) [CHAR] a [CHAR] z 1+ WITHIN ;
  : TOUPPER ( c -- c') DUP ?LOWER IF 5F AND THEN ;
  : INKEY   ( -- c)    KEY 7F AND TOUPPER ;
  DECIMAL
```

## What difference does it make?
The differences above are quite striking. You don't typically chop up code this
way in traditional procedural languages. The primary reason for that is the
over- head for calling a sub-routine can be quite high in other languages.

However Chuck Moore designed Forth to reduce that calling over-head. This gives
the programmer more freedom to factor out common code from long sub- routines.

### More Re-usable Code
As we can see in the example factoring out and naming these code pieces allows
us to re-use them elsewhere as needed. Here we now have a test word for lower
case letters and a word to convert lower case to upper case. The original code
gave one "fossilized" sub-routine that could only do one thing.

### Make Your Life Simpler
Another reason for the Forth "style" is because stack programming is hard. There
I said it.  Yes it is harder to code for a stack machine that using name
variables. The compensation for that is factoring. That is how the language
designer wanted us to use Forth.  By cutting things into small pieces
stack contents become much simpler almost trivial. If you can remember what is
on the top of the data stack 20 lines into a sub-routine then you are a genius
but us mere mortals don't need to do that. We just factor the code into more
understandable pieces.

### Less Comments Required
On of the side-effects of one line definitions is that you can understand them
almost instantly. This means expansive text comments are not as necessary and we
all know how fast comments go stale. BUT... Do not omit the stack comments.
These are the key to remembering what goes in and what comes out of each
definition.

### To be continued...
As I think find more examples of good Forth coding style I will put them here.
