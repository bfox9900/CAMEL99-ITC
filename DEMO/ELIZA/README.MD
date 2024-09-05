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
'''
Here we see the ?y inserted into the reply text seamlessly.
This creates a much more natural reply than simply appending
the subject text to the end of a reply phrase. 

The equivalent code in this DSL would be:
```
KEY" DREAM ABOUT"
{  ::  CR ." How do you feel about " <rogerian> ." in reality?" ;
} REPLY: DREAMABOUT 
```

With a little effort this could be further simplfied. 