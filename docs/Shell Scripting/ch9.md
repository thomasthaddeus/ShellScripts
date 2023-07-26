## CHAPTER 9

Reserved Words and Built-In Commands
There are almost 60 built-in commands and more than 20 reserved words in bash. Some of them are indispensable, and some are rarely used in scripts. Some are used primarily at the command line, and some are seldom seen anywhere. Some have been discussed already, and others will be used extensively in future chapters.
The reserved words (also called keywords) are !, case, coproc, do, done, elif, else, esac, fi, for, function, if, in, select, then, until, while, {, }, time, [[, and ]]. All except coproc, select, and time have been covered earlier in the book.
In addition to the standard commands, new built-in commands can be dynamically loaded into the shell at runtime. The bash source code package has more than 20 such commands ready to be compiled.
Because keywords and built-in commands are part of the shell itself, they execute much faster than external commands. They do not have to start a new process, and they have access to, and can change, the shell’s environment.
This chapter looks at some of the more useful reserved words and built-in commands, examining some in detail and some with a summary; a few are deprecated. Many more are described elsewhere in the book. For the rest, there is the builtins man page and the help built-in.
help, Display Information About Built-In Commands
The help command prints brief information about the usage of built-in commands and reserved words. With the -s option, it prints a usage synopsis.
Two new options are available with bash-4.x: -d and -m. The first prints a short, one-line description of the command; the latter formats the output in the style of a man page:
$ help -m help
NAME
    help - Display information about builtin commands.

SYNOPSIS
    help [-dms] [pattern ...]

DESCRIPTION
    Display information about builtin commands.

    Displays brief summaries of builtin commands. If PATTERN is
    specified, gives detailed help on all commands matching PATTERN,
    otherwise the list of help topics is printed.

    Options:
      -d        output short description for each topic
      -m        display usage in pseudo-manpage format
      -s        output only a short usage synopsis for each topic matching
        PATTERN

    Arguments:
      PATTERN   Pattern specifying a help topic

    Exit Status:
    Returns success unless PATTERN is not found or an invalid option is given.

SEE ALSO
    bash(1)

IMPLEMENTATION
    GNU bash, version 4.3.30(1)-release (i686-pc-linux-gnu)
    Copyright (C) 2013 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
The pattern is a globbing pattern, in which * matches any number of any characters and [...] matches any single character in the enclosed list. Without any wildcard, a trailing * is assumed:
$ help -d '*le' tr ## show commands ending in le and beginning with tr
Shell commands matching keyword '*le, tr'

enable - Enable and disable shell builtins.
mapfile - Read lines from the standard input into an array variable.
while - Execute commands as long as a test succeeds.
trap - Trap signals and other events.
true - Return a successful result.
time, Print Time Taken for Execution of a Command
The reserved word, time, prints the time it takes for a command to execute. The command can be a simple or compound command or a pipeline. The default output appears on three lines, showing the real time, user CPU time, and system CPU time that was taken by the command:
$ time echo {1..30000} >/dev/null 2>&1

real    0m0.175s
user    0m0.152s
sys     0m0.017s
You can modify this output by changing the TIMEFORMAT variable:
$ TIMEFORMAT='%R seconds  %P%% CPU usage'
$ time echo {1..30000} >/dev/null
0.153 seconds  97.96% CPU usage
The Appendix contains a full description of the TIMEFORMAT variable.
A frequently asked question about the time command is, “Why can’t I redirect the output of time?” The answer demonstrates a difference between a reserved word and a built-in command. When the shell executes a command, the process is strictly defined. A shell keyword doesn’t have to follow that procedure. In the case of time, the entire command line (with the exception of the keyword itself but including the redirection) is passed to the shell to execute. When the command has completed, the timing information is printed.
To redirect the output of time, enclose it in braces:
$ { time echo {1..30000} >/dev/null 2>&1 ; } 2> numlisttime
$ cat numlisttime
0.193 seconds  90.95% CPU usage
read, Read a Line from an Input Stream
If read has no arguments, bash reads a line from its standard input stream and stores it in the variable REPLY. If the input contains a backslash at the end of a line, it and the following newline are removed, and the next line is read, joining the two lines:
$ printf "%s\n" '   First line   \' '   Second line   ' | {
> read
> sa "$REPLY"
> }
:   First line      Second line   :
  Note  The braces ({ }) in this and the following snippets create a common subshell for both the read and sa commands. Without them, read would be in a subshell by itself, and sa would not see the new value of REPLY (or of any other variable set in the subshell).
Only one option, -r, is part of the POSIX standard. The many bash options (-a, -d, -e, -n, -p, -s, -n, -t, -u, and, new to bash-4.x, -i) are part of what makes this shell work so well for interactive scripts.
-r, Read Backslashes Literally
With the -r option, backslashes are treated literally:
$ printf "%s\n" '   First line\' "   Second line   " | {
> read -r
> read line2
> sa "$REPLY" "$line2"
> }
:   First line\:
:Second line:
The second read in that snippet supplies a variable to store the input rather than using REPLY. As a result, it applies word splitting to the input, and leading and trailing spaces are removed. If IFS had been set to an empty string, then spaces would not be used for word splitting:
$ printf "%s\n" '   First line\' "   Second line   " | {
> read -r
> IFS= read line2
> sa "$REPLY" "$line2"
> }
:   First line\:
:   Second line   :
If more than one variable is given on the command line, the first field is stored in the first variable, and subsequent fields are stored in the following variables. If there are more fields than variables, the last one stores the remainder of the line:
$ printf "%s\n" "first second third fourth fifth sixth" | {
> read a b c d
> sa "$a" "$b" "$c" "$d"
> }
:first:
:second:
:third:
:fourth fifth sixth:
-e, Get Input with the readline Library
When at the command line or when using read with the -e option to get input from the keyboard, the readline library is used. It allows full-line editing. The default editing style, found in most shells, only allows editing by erasing the character to the left of the cursor with a backspace.
With -e, a backspace still works, of course, but the cursor can be moved over the entire line character by character with the arrow keys or with Ctrl-B and Ctrl-N for backward and forward, respectively. Ctrl-A moves to the beginning of the line, and Ctrl-E moves to the end.
In addition, other readline commands can be bound to whatever key combinations you like. I have Ctrl-left arrow bound to backward-word and Ctrl-right arrow to forward-word. Such bindings can be placed in $HOME/.inputrc. Mine has entries for two terminals, rxvt and xterm:
"\eOd": backward-word     ## rxvt
"\eOc": forward-word      ## rxvt
"\e[1;5D": backward-word  ## xterm
"\e[1;5C": forward-word   ## xterm
To check which code to use in your terminal emulation, press ^V (Ctrl-v) and then the key combination you want. For example, in xterm, I see ^[[1;5D when I press Ctrl-left arrow.
-a, Read Words into an Array
The -a option assigns the words read to an array, starting at index zero:
$ printf "%s\n" "first second third fourth fifth sixth" | {
> read -a array
> sa "${array[0]}"
> sa "${array[5]}"
> }
:first:
:sixth:
-d DELIM, Read Until DELIM Instead of a Newline
The -d option takes an argument that changes read’s delimiter from a newline to the first character of that argument:
$ printf "%s\n" "first second third fourth fifth sixth" | {
> read -d ' nrh' a
> read -d 'nrh' b
> read -d 'rh' c
> read -d 'h' d
> sa "$a" "$b" "$c" "$d"
> }
:first:          ## -d ' '
:seco:           ## -d n
:d thi:          ## -d r
:d fourt:        ## -d h
-n NUM, Read a Maximum of NUM Characters
Most frequently used when a single character (for example, y or n) is required, read returns after reading NUM characters rather than waiting for a newline. It is often used in conjunction with -s.
-s, Do Not Echo Input Coming from a Terminal
Useful for entering passwords and single-letter responses, the -s option suppresses the display of the keystrokes entered.
-p PROMPT:, Output PROMPT Without a Trailing Newline
The following snippet is a typical use of these three options:
read -sn1 -p "Continue (y/n)? " var
case ${var^} in  ## bash 4.x, convert $var to uppercase
  Y) ;;
  N) printf "\n%s\n" "Good bye."
     exit
     ;;
esac
When run, it looks like this when n or N is entered:
Continue (y/n)?
Good bye.
-t TIMEOUT, Only Wait TIMEOUT Seconds for Complete Input
The -t option was introduced in bash-2.04 and accepts integers greater than 0 as an argument. If TIMEOUT seconds pass before a complete line has been entered, read exits with failure; any characters already entered are left in the input stream for the next command that reads the standard input.
In bash-4.x, the -t option accepts a value of 0 and returns successfully if there is input waiting to be read. It also accepts fractional arguments in decimal format:
read -t .1 var  ## timeout after one-tenth of a second
read -t 2 var   ## timeout after 2 seconds
Setting the variable TMOUT to an integer greater than zero has the same effect as the -t option. In bash-4.x, a decimal fraction can also be used:
$ TMOUT=2.5
$ TIMEFORMAT='%R seconds  %P%% CPU usage'
$ time read
2.500 seconds  0.00% CPU usage
-u FD: Read from File Descriptor FD Instead of the Standard Input
The -u option tells bash to read from a file descriptor. Given this file:
First line
Second line
Third line
Fourth line
this script reads from it, alternating between redirection and the -u option, and prints all four lines:
exec 3<$HOME/txt
read var <&3
echo "$var"
read -u3 var
echo "$var"
read var <&3
echo "$var"
read -u3 var
echo "$var"
-i TEXT, Use TEXT as the Initial Text for Readline
New to bash-4.x, the -i option, used in conjunction with the -e option, places text on the command line for editing.
$ read –ei 'Edit this' -p '==>'
would look like
==> Edit this •
The bash-4.x script shown in Listing 9-1 loops, showing a spinning busy indicator, until the user presses a key. It uses four read options: -s, -n, -p, and -t.
Listing 9-1. spinner, Show Busy Indicator While Waiting for User to Press a Key
spinner="\|/-"              ## spinner
chars=1                     ## number of characters to display
delay=.15                   ## time in seconds between characters
prompt="press any key..."     ## user prompt
clearline="\e[K"            ## clear to end of line (ANSI terminal)
CR="\r"                     ## carriage return

## loop until user presses a key
until read -sn1 -t$delay -p "$prompt" var
do
  printf "  %.${chars}s$CR" "$spinner"
  temp=${spinner#?}               ## remove first character from $spinner
  spinner=$temp${spinner%"$temp"} ## and add it to the end
done
printf "$CR$clearline"
  Tip  If delay is changed to an integer, the script will work in all versions of bash, but the spinner will be very slow.
eval, Expand Arguments and Execute Resulting Command
In Chapter 5, the eval built-in was used to get the value of a variable whose name was in another variable. It accomplished the same task as bash’s variable expansion, ${!var}. What actually happened was that eval expanded the variable inside quotation marks; the backslashes removed the special meanings of the quotes and the dollar sign so that they remained the literal characters. The resulting string was then executed:
$ x=yes
$ a=x
$ eval "sa \"\$$a\"" ## executes: sa "$x"
yes
Other uses of eval include assigning values to a variable whose name is contained in another variable and obtaining more than one value from a single command.
Poor Man’s Arrays
Before bash had associative arrays (that is, before version 4.0), they could be simulated with eval. These two functions set and retrieve such values and take them for a test run (Listing 9-2).
Listing 9-2. varfuncs, Emulate Associative Arrays
validname() ## Borrowed from Chapter 7
 case $1 in
   [!a-zA-Z_]* | *[!a-zA-Z0-9_]* ) return 1;;
 esac

setvar() #@ DESCRIPTION: assign value to supplied name
{        #@ USAGE: setvar varname value
  validname "$1" || return 1
  eval "$1=\$2"
}

getvar() #@ DESCRIPTION: print value assigned to varname
{        #@ USAGE: getvar varname
  validname "$1" || return 1
  eval "printf '%s\n' \"\${$1}\""
}

echo "Assigning some values"
for n in {1..3}
do
  setvar "var_$n" "$n - $RANDOM"
done
echo "Variables assigned; printing values:"
for n in {1..3}
do
 getvar "var_$n"
done
Here’s a sample result from a run:
Assigning some values
Variables assigned; printing values:
1 - 28538
2 - 22523
3 - 19362
Note the assignment in setvar. Compare it with this:
setvar() { eval "$1=\"$2\""; }
If you substitute this function for the one in varfuncs and run the script, the results look very much the same. What’s the difference? Let’s try it with a different value, using stripped-down versions of the functions at the command line:
$ {
> setvar() { eval "$1=\$2"; }
> getvar() { eval "printf '%s\n' \"\${$1}\""; }
> n=1
> setvar "qwerty_$n" 'xxx " echo Hello"'
> getvar "qwerty_$n"
> }
xxx " echo hello"
$ {
> setvar2() { eval "$1=\"$2\""; }
> setvar2 "qwerty_$n" 'xxx " echo Hello"'
> }
Hello
Hello? Where did that come from? With set -x, you can see exactly what is happening:
$ set -x ## shell will now print commands and arguments as they are executed
$ setvar "qwerty_$n" 'xxx " echo Hello"'
+ setvar qwerty_1 'xxx " echo Hello"'
+ eval 'qwerty_1=$2'
The last line is the important one. There the variable qwerty_1 is set to whatever is in $2. $2 is not expanded or interpreted in any way; its value is simply assigned to qwerty_1:
$ setvar2 "qwerty_$n" 'xxx " echo Hello"'
+ setvar2 qwerty_1 'xxx " echo Hello"'
+ eval 'qwerty_1="xxx " echo Hello""'
++ qwerty_1='xxx '
++ echo HelloHello
In this version, $2 is expanded before the assignment and is therefore subject to word splitting; eval sees an assignment followed by a command. The assignment is made, and then the command is executed. In this case, the command was harmless, but if the value had been entered by a user, it could have been something dangerous.
To use eval safely, ensure that the unexpanded variable is presented for assignment using eval "$var=\$value". If necessary, combine multiple elements into one variable before using eval:
string1=something
string2='rm -rf *' ## we do NOT want this to be executed
eval "$var=\"Example=$string1\" $string2" ## WRONG!! Files gone!
combo="Example=$string1 $string2"
eval "$var=\$combo" ## RIGHT!
The value of the variable whose name is in var is now the same as the contents of combo, if var was set to xx:
$ printf "%s\n" "$xx"
Example=something rm -rf *
Setting Multiple Variables from One Command
I have seen many scripts in which several variables are set to components of the date and time using this command (or something similar):
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
hour=$(date +%H)
minute=$(date +%M)
second=$(date +%S)
This is inefficient because it calls the date command six times. It could also give the wrong results. What happens if the script is called a fraction of a second before midnight and the date changes between setting the month and day? The script was called at 2009-05-31T23:59:59 (this is the ISO standard format for date and time), but the values assigned could amount to 2009-05-01T00:00:00. The date that was wanted was 31 May 2009 23:59:59 or 01 June 2009 00:00:00; what the script got was 1 May 2009 00:00:00. That’s a whole month off!
A better method is to get a single string from date and split it into its parts:
date=$(date +%Y-%m-%dT%H:%M:%S)
time=${date#*T}
date=${date%T*}
year=${date%%-*}
daymonth=${date#*-}
month=${daymonth%-*}
day=${daymonth#*-}
hour=${time%%:*}
minsec=${time#*-}
minute=${minsec%-*}
second=${minsec#*-}
Better still, use eval:
$ eval "$(date "+year=%Y month=%m day=%d hour=%H minute=%M second=%S")"
The output of the date command is executed by eval:
year=2015 month=04 day=25 hour=22 minute=49second=04
The last two methods use only one call to date, so the variables are all populated using the same timestamp. They both take about the same amount of time, which is a fraction of the time of multiple calls to date. The clincher is that the eval method is about one-third as long as the string-splitting method.
type, Display Information About Commands
Many people use which to determine the actual command that will be used when one is executed. There are two problems with that.
The first is that there are at least two versions of which, one of which is a csh script that doesn’t work well in a Bourne-type shell (thankfully, this version is becoming very rare). The second problem is that which is an external command, and it cannot know exactly what the shell will do with any given command. All it does is search the directories in the PATH variable for an executable with the same name:
$ which echo printf
/bin/echo
/usr/bin/printf
You know that both echo and printf are built-in commands, but which doesn’t know that. Instead of which, use the shell built-in type:
$ type echo printf sa
echo is a shell builtin
printf is a shell builtin
sa is a function
sa ()
{
    pre=: post=:;
    printf "$pre%s$post\n" "$@"
}
When there’s more than one possible command that would be executed for a given name, they can all be shown by using the -a option:
$ type -a echo printf
echo is a shell builtin
echo is /bin/echo
printf is a shell builtin
printf is /usr/bin/printf
The -p option limits the search to files and does not give any information about built-ins, functions, or aliases. If the shell executes the command internally, nothing will be printed unless the -a option is also given:
$ type -p echo printf sa time  ## no output as no files would be executed
$ type -ap echo printf sa time
/bin/echo
/usr/bin/printf
/usr/jayant/bin/sa
/usr/bin/time
Or you can use -P:
$ type -P echo printf sa time
/bin/echo
/usr/bin/printf
/usr/jayant/bin/sa
/usr/bin/time
The -t option gives a single word for each command, either alias, keyword, function, builtin, file, or an empty string:
$ type -t echo printf sa time ls
builtin
builtin
function
keyword
file
The type command fails if any of its arguments are not found.
builtin, Execute a Built-In Command
The argument to builtin is a shell built-in command that will be called rather than a function with the same name. It prevents the function from calling itself and calling itself ad nauseam:
cd() #@ DESCRIPTION: change directory and display 10 most recent files
{    #@ USAGE: cd DIR
  builtin cd "$@" || return 1 ## don't call function recursively
  ls -t | head
}
command, Execute a Command or Display Information About Commands
With -v or -V, display information about a command. Without options, call the command from an external file rather than a function.
pwd, Print the Current Working Directory
pwd prints the absolute pathname of the current directory. With the -P option, it prints the physical location with no symbolic links:
$ ls -ld $HOME/Book   ## Directory is a symbolic link
lrwxrwxrwx  1 jayant jayant 10 Apr 25  2015 /home/jayant/Book -> work/Cook
$ cd $HOME/Book
$ pwd                 ## Include symbolic links
/home/jayant/Book
$ pwd -P              ## Print physical location with no links
/home/jayant/work/Book
unalias, Remove One or More Aliases
In my ~/.bashrc file, I have unalias -a to remove all aliases. Some GNU/Linux distributions make the dangerous mistake of defining aliases that replace standard commands.
One of the worst examples is the redefinition of rm (remove files or directories) to rm -i. If a person, used to being prompted before a file is removed, puts rm * (for example) in a script, all the files will be gone without any prompting. Aliases are not exported and, by default, not run in shell scripts, even if defined.
Deprecated Built-Ins
I don’t recommend using the following deprecated built-in commands:
   + alias: Defines an alias. As the bash man page says, “For almost every purpose, aliases are superseded by shell functions.”
   + let: Evaluates arithmetic expressions. Use the POSIX syntax $(( expression )) instead.
   + select: An inflexible menuing command. Much better menus can be written easily with the shell.
   + typeset: Declares a variable’s attributes and, in a function, restricts a variable’s scope to that function and its children. Use local to restrict a variable’s scope to a function, and use declare to set any other attributes (if necessary).
Dynamically Loadable Built-Ins
Bash can load new built-in commands at runtime if or when needed. The bash source package has a directory full of examples ready to be compiled. To do that, download the source from ftp://ftp.cwru.edu/pub/bash/. Unpack the tarball, cd into the top level directory, and run the configure script:
version=4.3 ## or use your bash version
wget ftp://ftp.cwru.edu/pub/bash/bash-$version.tar.gz
gunzip bash-$version.tar.gz
tar xf bash-$version.tar
cd bash-$version
./configure
  Note  It would be recommended to use 4.3 as the version since it is the current version and has bug fixes for vulnerabilitites that were found in earlier versions.
Think of dynamically loadable built-ins as cutom libraries of commands that are written in C and available as compiled binaries. These can also be shared with others in the compiled form. When loaded they provide new command or commands that were originally not available in Bash. These work like native Bash commands than external scripts or programs.
The configure script creates makefiles throughout the source tree, including one in examples/loadables. In that directory are the source files for built-in versions of a number of standard commands, as the README file says, “whose execution time is dominated by process startup time.” You can cd into that directory and run make:
cd examples/loadables
make
You’ll now have a number of commands ready to load into your shell. These include the following:
logname  tee       head      mkdir     rmdir     uname
ln       cat       id        whoami
There are also some useful new commands:
print     ## Compatible with the ksh print command
finfo     ## Print file information
strftime  ## Format date and time
These built-ins can be loaded into a running shell with the following command:
enable -f filename built-in-name
The files include documentation, and the help command can be used with them, just as with other built-in commands:
$ enable -f ./strftime strftime
$ help strftime
strftime: strftime format [seconds]
    Converts date and time format to a string and displays it on the
    standard output.  If the optional second argument is supplied, it
    is used as the number of seconds since the epoch to use in the
    conversion, otherwise the current time is used.
For information on writing dynamically loadable built-in commands, see this article at http://shell.cfajohnson.com/articles/dynamically-loadable/.
Summary
You learned about the following commands in this chapter.
Commands and Reserved Words
   + builtin: Executes a built-in command
   + command: Executes an external command or print information about a command
   + eval: Executes arguments as a shell command
   + help: Displays information about built-in commands
   + pwd: Prints the current working directory
   + read: Reads a line from the standard input and splits it into fields
   + time: Reports time consumed by pipeline’s execution
   + type: Displays information about command type
Deprecated Commands
   + alias: Defines or display aliases
   + let: Evaluates arithmetic expressions
   + select: Selects words from a list and execute commands
   + typeset: Sets variable values and attributes
Exercise
Write a script that stores the time it takes a command (your choice of command) to run in three variables, real, user, and system, corresponding to the three default times that time prints.
