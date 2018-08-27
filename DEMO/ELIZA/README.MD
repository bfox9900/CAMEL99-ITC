# Eliza In Forth

This version of the classic Lisp demonstration is a littel less sophistated than the original. A future version may allow progamming the responses in Forth allowing for more interesting responses like "In what way is 'X'  like 'Y'?" .  These were part of the original Lisp version and make the chatbot seem more life-like.

##Overview

This implementation creates simple string list syntax in Forth to help manage the replies. A simple string stack provides simple dynamic string creation but the program could have been written without it. 

By parsing the user text the program scans for keywords and key phrases. The matched text is coverted into a Forth word by removing spaces and punctionation.  Armed with a a valid Forth word we simply pass it to EVALUATE to kick off Eliza's response.

Lists of responses are created and compiled with the word REPLY: <name>

Using the list structure for keywords, phrases and conjugations coupled with directly executing Forth "REPLYs" makes modification quite simple.