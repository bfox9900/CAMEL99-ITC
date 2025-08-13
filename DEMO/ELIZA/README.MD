# Eliza In Forth

This version of the classic Lisp demonstration in version 3
has been re-written to use the Forth colon definition rather
than strings, as is commonly done in other languages.
A small DSL (domain specific language) was created to allow
the creation of key words and replies that was closer to the
power of LISP.

I was motivated to change the program after looking at the
LISP version of Eliza where you can see LISP's powerful
use of "code" as data.

For example:
```
(((?* ?x) dream about (?* ?y))
    (How do you feel about ?y in reality?))
```
Here we see the ?y inserted into the reply text seamlessly.
This creates a much more natural reply than simply appending
the subject text to the end of a reply phrase.

The equivalent code in this DSL would be:
```
KEY" DREAM ABOUT"
: DREAMABOUT  CR ." How do you feel about " <TOPIC> ." in reality?" ;

```
Where the word KEY" puts the string into a searchable array.
The colon definition is the "flattened" version of the string
When the phrase "dream about" is found in the input text, it is
flattened, converted to upper case and fed to the Forth interpreter.

<TOPIC> inserts the text that was parsed after the key phrase.
the rest of the definition is nothing but standard Forth.

The definition of topic is below.

```
: <TOPIC>  ( -- )
  INPUT$ COUNT /TAIL DUP 0= IF 2DROP EXIT THEN
  PUNCTUATION$ STRIP  /CONJUGATE  ;

: <TOPIC?>  <TOPIC> '?' ;
```

With a little more effort we could make an operator the creates
a dictionary entry of the flattened phrase automagically.
