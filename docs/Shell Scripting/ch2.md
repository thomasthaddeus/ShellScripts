## CHAPTER 2

### Input, Output, and Throughput

Two of the commands we used in Chapter 1 are workhorses of the shell scripter’s stable: echo and printf. Both are bash builtin commands. Both print information to the standard output stream, but printf is much more powerful, and echo has its problems.
In this chapter, I’ll cover echo and its problems, the capabilities of printf, the read command, and the standard input and output streams. I’ll start, however, with an overview of parameters and variables.

### Parameter and Variables

To quote the bash manual (type man bash at the command prompt to read it), “A parameter is an entity that stores values.” There are three types of parameters: positional parameters, special parameters, and variables. Positional parameters are arguments present on the command line, and they are referenced by a number. Special parameters are set by the shell to store information about aspects of its current state, such as the number of arguments and the exit code of the last command. Their names are nonalphanumeric characters (for example, \*, #, and \_). Variables are identified by a name. What’s in a name? I’ll explain that in the “Variables” section.
The value of a parameter is accessed by preceding its name, number, or character with a dollar sign, as in $3, $#, or $HOME. The name may be surrounded by braces, as in ${10}, ${PWD}, or ${USER}.

### Positional Parameters

The arguments on the command line are available to a shell program as numbered parameters. The first argument is $1, the second is $2, and so on.
You can make the hw script from Chapter 1 more flexible by using a positional parameter. Listing 2-1 calls it hello.
**Listing 2-1.** `hello`

```bash
#: Description: print Hello and the first command-line argument
printf "Hello, %s!\n" "$1"
```

Now you can call the script with an argument to change its output:

```bash
$ hello John
Hello, John!
$ hello Susan
Hello, Susan!
```

The Bourne shell could only address up to nine positional parameters. If a script used `$10`, it would be interpreted as `$1` followed by a zero. To be able to run old scripts, bash maintains that behavior. To access positional parameters greater than 9, the number must be enclosed in braces: `${15}.`
The script is passed to the parameters that can be accessed via their positions, `$0`, `$1`, `$2` and so on. The function shift `N` moves the positional parameters by N positions, if you ran shift (the default value of N is 1), then $0 would be discarded, $1 would become $0, $2 would become $1, and so on: they would all be shifted by 1 position. There are some very clever and simple uses of shift to iterate through a list of paramters of unknown length.
Note The shift function is distructive: that is, the paramters discarded are gone and cannot be retrieved again.

### Special `*@#0$?_!-` Parameters

The first two special parameters, `$*` and `$@,` expand to the value of all the positional parameters combined. $# expands to the number of positional parameters. $0 contains the path to the currently running script or to the shell itself if no script is being executed.
$$ contains the process identification number (PID) of the current process, $? is set to the exit code of the last-executed command, and $\_ is set to the last argument to that command. $! contains the PID of the last command executed in the background, and $- is set to the option flags currently in effect.
I’ll discuss these parameters in more detail as they come up in the course of writing scripts.
Variables
A variable is a parameter denoted by a name; a name is a word containing only letters, numbers, or underscores and beginning with a letter or an underscore.
Values can be assigned to variables in the following form:
name=VALUE
Note Bash is very particular about spacing: note that there are no spaces before the = and none after. If you have spaces, the command would not work.
Many variables are set by the shell itself, including three you have already seen: HOME, PWD, and PATH. With only two minor exceptions, auto_resume and histchars, all the variables set by the shell are all uppercase letters.

### Arguments and Options

The words entered after the command are its arguments. These are words separated by whitespace (one or more spaces or tabs). If the whitespace is escaped or quoted, it no longer separates words but becomes part of the word.
The following command lines all have four arguments:

```bash
echo 1 '2   3'   4 5
echo  -n  Now\ is  the  time
printf "%s %s\n" one two three
```

In the first line, the spaces between 2 and 3 are quoted because they are surrounded by single quotation marks. In the second, the space after now is escaped by a backslash, which is the shell’s escape character.
In the final line, a space is quoted with double quotes.
In the second command, the first argument is an option. Traditionally, options to Unix commands are a single letter preceded by a hyphen, sometimes followed by an argument. The GNU commands found in Linux distributions often accept long options as well. These are words preceded by a double hyphen. For example, most GNU utilities have an option called --version that prints the version:
$ bash --version
GNU bash, version 4.3.11(1)-release (x86_64-unknown-linux-gnu)

Copyright (C) 2013 Free Software Foundation, Inc.

License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
echo, and Why You Should Avoid It
When I started writing shell scripts, I soon learned about the two main branches of Unix: AT&T’s System V and BSD. One of their differences was the behavior of echo. An internal command in all modern shells, echo prints its arguments with a single space between them to the standard output stream, followed by a newline:
$ echo The quick brown fox
The quick brown fox
The default newline can be suppressed in one of two ways, depending on the shell:
$ echo -n No newline
No newline$ echo "No newline\c"
No newline$
The BSD variety of echo accepted the option -n, which suppressed the newline. AT&T’s version used an escape sequence, \c, to do the same thing. Or was it the other way round? I have a hard time remembering which was which because, although I was using an AT&T system (hardware and operating system), its echo command accepted both AT&T and BSD syntax.
That, of course, is history. In this book, we’re dealing with bash, so why does it matter? bash has the -e option to activate escape sequences such as \c but by default uses -n to prevent a newline from being printed. (The escape sequences recognized by echo -e are the same as those described in the next section, with the addition of \c).
Tip Add –e to the echo command if you want the escape sequences to be recognized.
The trouble is that bash has an xpg_echo option (XPG stands for X/Open Portability Guide, a specification for Unix systems) that makes echo behave like that other version. This can be turned on or off while in the shell (using shopt -s xpg_echo either at the command line or in a script), or it can be turned on when the shell is compiled. In other words, even in bash, you cannot be absolutely sure which behavior you are going to get.
If you limit the use of echo to situations where there cannot be a conflict, that is, where you are sure the arguments do not begin with -n and do not contain escape sequences, you will be fairly safe. For everything else (or if you’re not sure), use printf.
printf: Formatting and Printing Data
Derived from the C programming language function of the same name, the shell command printf is similar in purpose but differs in some of the details. Like the C function, it uses a format string to indicate how to present the rest of its arguments:
printf FORMAT ARG ...
The FORMAT string can contain ordinary characters, escape sequences, and format specifiers. Ordinary characters are printed unchanged to the standard output. Escape sequences are converted to the characters they represent. Format specifiers are replaced with arguments from the command line.
Escape Sequences Escape sequences are single letters preceded by a backslash:

```Regex
\a: : Alert (bell)
\b: Backspace
\e: Escape character
\f: Form feed
\n: Newline
\r: Carriage return
\t: Horizontal tab
\v: Vertical tab
\\: Backslash
\nnn: A character specified by one to three octal digits
\xHH: A character specified by one or two hexadecimal digits
```

The backslashes must be protected from the shell by quotes or another backslash:

```bash
$  printf "Q\t\141\n\x42\n"
Q       a
B
```

### Format Specifiers

The format specifiers are letters preceded by a percent sign. Optional modifiers may be placed between the two characters. The specifiers are replaced by thecorresponding argument. When there are more arguments than specifiers, the format string is reused until all the arguments have been consumed. The most commonly used specifiers are %s, %d, %f, and %x.
The %s specifier prints the literal characters in the argument:
$ printf "%s\n" Print arguments on "separate lines"
Print
arguments
on
separate lines
%b is like %s except that escape sequences in the arguments are translated:
$ printf "%b\n" "Hello\nworld" "12\tword"
Hello
world
12 word
Integers are printed with %d. The integer may be specified as a decimal, octal (using a leading 0), or hexadecimal (preceding the hex number with 0x) number. If the number is not a valid integer, printf prints an error message:
$ printf "%d\n" 23 45 56.78 0xff 011
23
45
bash: printf: 56.78: invalid number
0
255
9
For decimal fractions or floating-point numbers, use %f. By default they will be printed with six decimal places:
$ printf "%f\n" 12.34 23 56.789 1.2345678
12.340000
23.000000
56.789000
1.234568
Floating-point numbers can be presented in exponential (also known as scientific) notation using `%e`:

```bash
$ printf "%e\n" 12.34 23 56.789 123.45678
1.234000e+01
2.300000e+01
5.678900e+01
1.234568e+02
```

Integers can be printed in hexadecimal using `%x` for lowercase letters or %X for uppercase letters. For example, when specifying colors for a web page, they are specified in hex notation. I know from the rgb.txt file included with the X Window system that the red-green-blue values for royal blue are 65, 105, and 225. To convert them to a style rule for a web page, use this:
$ printf "color: #%02x%02x%02x;\n" 65 105 225
color: #4169e1;
Width Specification
You can modify the formats by following the percent sign with a width specification. The argument will be printed flush right in a field of that width or will be flush left if the number is negative. Here we have the first field with a width of eight characters; the words will be printed flush right. Then there is a field 15 characters wide that will be printed flush left:
$ printf "%8s %-15s:\n" first second third fourth fifth sixth
first second :
third fourth :
fifth sixth :
If the width specification is preceded by a 0, the numbers are padded with leading zeroes to fill the width:
$ printf "%04d\n" 12 23 56 123 255
0012
0023
0056
0123
0255
A width specifier with a decimal fraction specifies the precision of a floating-point number or the maximum width of a string:
$ printf "%12.4s %9.2f\n" John 2 Jackson 4.579 Walter 2.9
John 2.00
Jack 4.58
Walt 2.90
The script shown in. Listing 2-2 uses printf to output a simple sales report.
Listing 2-2. Report

```bash
#!/bin/bash
#: Description : print formatted sales report

## Build a long string of equals signs
divider=====================================
divider=$divider$divider

## Format strings for printf
header="\n %-10s %11s %8s %10s\n"
format=" %-10s %11.2f %8d %10.2f\n"

## Width of divider
totalwidth=44

## Print categories
printf "$header" ITEM  "PER UNIT" NUM TOTAL

## Print divider to match width of report
printf "%$totalwidth.${totalwidth}s\n" "$divider"

## Print lines of report
printf "$format" \
    Chair 79.95 4 319.8 \
   Table  209.99 1 209.99 \
   Armchair 315.49 2 630.98
```

The resulting report looks like this:
ITEM PER UNIT NUM TOTAL
============================================
Chair 79.95 4 319.80
Table 209.99 1 209.99
Armchair 315.49 2 630.98
Note the use of braces around the second totalwidth variable name: ${totalwidth}. In the first instance, the name is followed by a period, which cannot be part of a variable name. In the second, it is followed by the letter s, which could be, so the totalwidth name must be separated from it by using braces.
Printing to a Variable
With version 3.1, bash added a -v option to store the output in a variable instead of printing it to the standard output:
$ printf -v num4 "%04d" 4
$ printf "%s\n" "$num4"
0004

Line Continuation

At the end of the report script, the last four lines are read as a single line, using line continuation. A backslash at the end of a line tells the shell to ignore the newline character, effectively joining the next line to the current one.

Standard Input/Output Streams and Redirection

In Unix (of which Linux is a variety), everything is a stream of bytes. The streams are accessible as files, but there are three streams that are rarely accessed by a filename. These are the input/output (I/O) streams attached to every command: standard input, standard output, and standard error. By default, these streams are connected to your terminal.
When a command reads a character or a line, it reads from the standard input stream, which is the keyboard. When it prints information, it is sent to the standard output, your monitor. The third stream, standard error, is also connected to your monitor; as the name implies, it is used for error messages. These streams are referred to by numbers, called file descriptors (FDs). These are 0, 1, and 2, respectively. The stream names are also often contracted to stdin, stdout, and stderr.
I/O streams can be redirected to (or from) a file or into a pipeline.

Redirection: >, >>, and <

In Chapter 1, you redirected standard output to a file using the > redirection operator.
When redirecting using >, the file is created if it doesn’t exist. If it does exist, the file is truncated to zero length before anything is sent to it. You can create an empty file by redirecting an empty string (that is, nothing) to the file:
printf "" > FILENAME
or by simply using this:

```bash
> FILENAME
```

Redirection is performed before any command on the line is executed. If you redirect to the same file you are reading from, that file will be truncated, and the command will have nothing to read.
The >> operator doesn’t truncate the destination file; it appends to it. You could add a line to the hw command from the first chapter by doing the following:
echo exit 0 >> bin/hw
Redirecting standard output does not redirect standard error. Error messages will still be displayed on your monitor. To send the error messages to a file – in other words, to redirect FD2 – the redirection operator is preceded by the FD.
Both standard output and standard error can be redirected on the same line. The next command sends standard output to FILE and standard error to ERRORFILE:
$ printf '%s\n%v\n' OK? Oops! > FILE 2> ERRORFILE
$ cat ERRORFILE
bash4: printf: `v': invalid format character
In this case, the error message is going to a special file, /dev/null. Sometimes called the bit bucket, anything written to it is discarded.
printf '%s\n%v\n' OK? Oops! 2>/dev/null
Instead of sending output to a file, it can be redirected to another I/O stream by using >&N where N is the number of the file descriptor. This command sends both standard output and standard error to FILE:
printf '%s\n%v\n' OK? Oops! > FILE 2>&1
Here, the order is important. The standard output is sent to FILE, and then standard error is redirected to where standard output is going. If the order is reversed, the effect is different. The redirection sends standard error to wherever standard output is currently going and then changes where standard output goes. Standard error still goes to where standard output was originally directed:
printf '%s\n%v\n' OK? Oops! 2>&1 > FILE
bash has also a nonstandard syntax for redirecting both standard output and standard error to the same place:
&> FILE
To append both standard output and standard error to FILE, use this:
&>> FILE
A command that reads from standard input can have its input redirected from a file:
tr, H wY < bin/hw
You can use the exec command to redirect the I/O streams for the rest of the script or until it’s changed again.
exec 1>tempfile
exec 0<datafile
exec 2>errorrfile
All standard output will now go to the file tempfile, input will be read from datafile, and error messages will go to errorfile without having to specify it for every command.
Reading Input
The read commandis a builtin command that reads from the standard input. By default, it reads until a newline is received. The input is stored in one or more variables given as arguments:
read var
If more than one variable is given, the first word (the input up to the first space or tab) is assigned to the first variable, the second word is assigned to the second variable, and so on, with any leftover words assigned to the last one:

```bash
$ read a b c d
January February March April May June July August
$ echo $a
January
$ echo $b
February
$ echo $c
March
$ echo $d
April May June July August

```

The bash version of read has several options. Only the -r option is recognized by the POSIX standard. It tells the shell to interpret escape sequences literally.
By default, read strips backslashes from the input, and the following character is taken literally. The major effect of this default behavior is to allow the continuation of lines. With the -r option, a backslash followed by a newline is read as a literal backslash and the end of input.
I’ll discuss the other options in Chapter 15.
Like any other command that reads standard input, read can get its input from a file through redirection. For example, to read the first line from FILENAME, use this:
read var < FILENAME
Pipelines
Pipelines connect the standard output of one command directly to the standard input of another. The pipe symbol (|) is used between the commands:
$ printf "%s\n" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" | tee FILENAME
618
11267
5890
8930
The tee command reads from the standard input and passes it to one or more files as well as to the standard output. $RANDOM is a bash variable that returns a different integer between 0 and 32,767 each time it is referenced.
$ cat FILENAME
618
11267
5890
8930

## Command Substitution

The output of a command can be stored in a variable using command substitution. There are two forms for doing this. The first, which originated in the Bourne shell, uses backticks:
date=`date`
The newer (and recommended) syntax is as follows:
date=$( date )
Command substitution should generally be reserved for external commands. When used with a builtin command, it is very slow. That is why the -v option was added to printf.
Summary
The following are the commands and concepts you learned in this chapter.

1. Commands

   - cat: Prints the contents of one or more files to the standard output
   - tee: Copies the standard input to the standard output and to one or more files
   - read: A builtin shell command that reads a line from the standard input
   - date: Prints the current date and time

2. Concepts
   - Standard I/O streams: These are streams of bytes from which commands read and to which output is sent.
   - Arguments: These are words that follow a command; arguments may include options as well as other information such as filenames.
   - Parameters: These are entities that store values; the three types are positional parameters, special parameters, and variables.
   - Pipelines: A pipeline is a sequence of one or more commands separated by |; the standard output of the command preceding the pipe symbol is fed to the standard input of the command following it.
   - Line continuation: This is a backslash at the end of a line that removes the newline and combines that line with the next.
   - Command substitution: This means storing the output of a command in a variable or on the command line.

#### Exercises

1. What is wrong with this command?

```bash
tr A Z < $HOME/temp > $HOME/temp
2.	Write a script, using $RANDOM, to write the following output both to a file and to a variable. The following numbers are only to show the format; your script should produce different numbers:
 1988.2365
13798.14178
10081.134
 3816.15098
```
