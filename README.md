# James Coglan's "A Simple Scheme In 20 Minutes"

## Description

A version of James Coglan's ["A Language In 20 Minutes"](https://www.youtube.com/watch?v=CqhL-BDT8lg for the whole 40 minute
presentation).  It took me about three hours to make this work.  This
version is tighter, using Coffeescript and PegJS instead of Javascript
and whatever parser/lexer he described.  

## Purpose

When I went to university, my degree was deliberately steered away from
the esoterica of compilers and interpreters.  My degree and financial
backing was predicated on my getting "practical" programming skills, so
I took classes in COBOL, Fortran, ADA, SQL, Accounting, and similar
subjects intended to make me a "financial products" programmer.

The Internet came along and gave me a much more interesting career, but
now it's time to rectify the shortcoming of my education and study
programming languages themselves.  This is a "My First Programming
Lanugage."

## Usage

It only has three special forms: 'define', 'lambda', and 'if'.  It
understands addition, subtraction, multiplication, division, and
equality for the purposes of the 'if' special form, although it's
clearly treating arithmetic as 'special forms' for the purpose of doing
the math.  It's good enough to handle lexical scoping and recursion, and
it handles basic integer arithmetic.  There is a bug is the lexer such
that symbols that start with a numeral won't be read right, but I'm too
lazy to fix it.

It has no macros.  Sorry about that.

## Requirements

Coffeescript, pegjs.

## LICENSE AND COPYRIGHT NOTICE: NO WARRANTY GRANTED OR IMPLIED

Copyright (c) 2015 Elf M. Sternberg

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

