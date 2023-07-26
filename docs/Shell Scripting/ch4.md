CHAPTER 4

Command-Line Parsing and Expansion
One of the strengths of the shell as a programming language is its parsing of command-line arguments and the various expansions it performs on words in the line. When a command is called with arguments, the shell does several things before it invokes the command.
To help visualize what happens, the short script shown in Listing 4-1, called ba, will display what the shell has passed to it after processing all the arguments. Each of its arguments is printed on a separate line, preceded by the value of $pre and followed by the value of $post.
Listing 4-1. ba; Displaying Command-Line Arguments
pre=:
post=:
printf "$pre%s$post\n" "$@"
Note: Create a script called sa with the text as can be seen in Listing 4-1. This is that is used in the code samples in this chapter.
The special parameter $@ expands to a list of all the command-line arguments, but the results differ depending on whether it is quoted or not. When quoted, it expands to the positional parameters "$1", "$2", "$3", "$4", and so on, and the arguments containing whitespace will be preserved. If $@ is unquoted, splitting will occur wherever there is whitespace.
When a line is executed, whether at the command prompt or in a script, the shell splits the line into words wherever there is unquoted whitespace. Then bash examines the resulting words, performing up to eight types of expansion on them as appropriate. The results of the expansions are passed to the command as its arguments. This chapter examines the entire process, from the initial parsing into words based on unquoted whitespace to each of the expansions in the order in which they are performed:
1.	Brace expansion
2.	Tilde expansion
3.	Parameter and variable expansion
4.	Arithmetic expansion
5.	Command substitution
6.	Word splitting
7.	Pathname expansion
8.	Process substitution
The chapter ends with a shell program that demonstrates how to parse options (arguments beginning with a hyphen) on the command line, using the getopts built in command.
Quoting
The shell’s initial parsing of the command line uses unquoted whitespace, that is, spaces, tabs, and newlines, to separate the words. Spaces between single or double quotes or spaces preceded by the escape character (\) are considered part of the surrounding word, if any. The delimiting quotation marks are stripped from the arguments.
The following code has five arguments. The first is the word this preceded by a space (the backslash removes its special meaning). The second argument is 'is a'; the entire argument is enclosed in double quotes, again removing the special meaning from the space. The phrase, demonstration of, is enclosed in single quotes. Next is a single, escaped space. Finally, the string quotes and escapes are held together by the escaped spaces.
$ sa \ this "is a" 'demonstration of' \  quotes\ and\ escapes
: this:
:is a:
:demonstration of:
: :
:quotes and escapes:
Quotes can be embedded in a word. Inside double quotes, a single quote is not special, but a double quote must be escaped. Inside single quotes, a double quote is not special.
$ sa "a double-quoted single quote, '" "a double-quoted double quote, \""
:a double-quoted single quote, ':
:a double-quoted double quote, ":
$ sa 'a single-quoted double quotation mark, "'
:a single-quoted double quotation mark, ":
All characters inside a single-quoted word are taken literally. A single-quoted word cannot contain a single quote even if it is escaped; the quotation mark will be regarded as closing the preceding one, and another single quote opens a new quoted section. Consecutive quoted words without any intervening whitespace are considered as a single argument:
$ sa "First argument "'still the first argument'
:First argument still the first argument:
In bash, single quotes can be included in words of the form $'string' if they are escaped. In addition, the escape sequences listed in Chapter 2’s description of printf are replaced by the characters they represent:

$ echo $'\'line1\'\n\'line2\''
'line1'
'line2'
Quoted arguments can contain literal newlines:
$ sa "Argument containing
> a newline"
:Argument containing
a newline:
  Note  The  is the enter key and not something to be typed on the terminal. Since the shell determines that the command is incomplete, it displays a > prompt allowing you to complete the command.
Brace Expansion
The first expansion performed, brace expansion, is non standard (that is, it is not included in the POSIX specification). It operates on unquoted braces containing either a comma-separated list or a sequence. Each element becomes a separate argument.
$ sa {one,two,three}
:one:
:two:
:three:
$ sa {1..3} ## added in bash3.0
:1:
:2:
:3:
$ sa {a..c}
:a:
:b:
:c:
A string before or after the brace expression will be included in each expanded argument:
$ sa pre{d,l}ate
:predate:
:prelate:
Braces may be nested:
$ sa {{1..3},{a..c}}
:1:
:2:
:3:
:a:
:b:
:c:
Multiple braces within the same word are expanded recursively. The first brace expression is expanded, and then each of the resulting words is processed for the next brace expression. With the word {1..3}{a..c}, the first term is expanded, giving the following:
1{a..c} 2{a..c} 3{a..c}
Each of these words is then expanded for this final result:
$ sa {1..3}{a..c}
:1a:
:1b:
:1c:
:2a:
:2b:
:2c:
:3a:
:3b:
:3c:
In version 4 of bash, further capabilities have been added to brace expansion. Numerical sequences can be padded with zeros, and the increment in a sequence can be specified:
$ sa {01..13..3}
:01:
:04:
:07:
:10:
:13:
Increments can also be used with alphabetic sequences:
$ sa {a..h..3}
:a:
:d:
:g:
Tilde Expansion
An unquoted tilde expands to the user’s home directory:
$ sa ~
:/home/chris:

Followed by a login name, it expands to that user’s home directory:
$ sa ~root ~chris
:/root:
:/home/chris:
When quoted, either on the command line or in a variable assignment, the tilde is not expanded:
$ sa "~" "~root"
:~:
:~root:
$ dir=~chris
$ dir2="~chris"
$ sa "$dir" "$dir2"
:/home/chris:
:~chris:
If the name following the tilde is not a valid login name, no expansion is performed:
$ sa ~qwerty
:~qwerty:
Parameter and Variable Expansion
Parameter expansion replaces a variable with its contents; it is introduced by a dollar sign ($). It is followed by the symbol or name to be expanded:
$ var=whatever
$ sa "$var"
:whatever:
The parameter may be enclosed in braces:
$ var=qwerty
$ sa "${var}"
:qwerty:
In most cases, the braces are optional. They are required when referring to a positional parameter greater than nine or when a variable name is followed immediately by a character that could be part of a name:
$ first=Jane
$ last=Johnson
$ sa "$first_$last" "${first}_$last"
:Johnson:
:Jane_Johnson:
Because first_ is a valid variable name, the shell tries to expand it rather than first; adding the braces removes the ambiguity.
Braces are also used in expansions that do more than simply return the value of a parameter. These often-cryptic expansions (${var##*/} and ${var//x/y}, for example) add a great deal of power to the shell and are examined in detail in the next chapter.
Parameter expansions that are not enclosed in double quotes are subject to word splitting and pathname expansion.
Arithmetic Expansion
When the shell encounters $(( expression )), it evaluates expression and places the result on the command line; expression is an arithmetic expression. Besides the four basic arithmetic operations of addition, subtraction, multiplication, and division, its most used operator is % (modulo, the remainder after division).
$ sa "$(( 1 + 12 ))" "$(( 12 * 13 ))" "$(( 16 / 4 ))" "$(( 6 - 9 ))"
:13:
:156:
:4:
:-3:
The arithmetic operators (see Tables 4-1 and 4-2) take the same precedence that you learned in school (basically, that multiplication and division are performed before addition and subtraction), and they can be grouped with parentheses to change the order of evaluation:
$ sa "$(( 3 + 4 * 5 ))" "$(( (3 + 4) * 5 ))"
:23:
:35:
Table 4-1. Arithmetic Operators
Operator	Description
-  +	Unary minus and plus
!  ~	Logical and bitwise negation
*  /  %	Multiplication, division, remainder
+ -	Addition, subtraction
<<  >>	Left and right bitwise shifts
<=  >=  < >	Comparison
== !=	Equality and inequality
&	Bitwise AND
^	Bitwise exclusive OR
|	Bitwise OR
&&	Logical AND
||	Logical OR
=  *=  /=  %=  +=  -=  <<=  >>=  &=  ^=  |=	Assignment
Table 4-2. bash Extensions
Operator	Description
**	Exponentiation
id++  id--	Variable post-increment and post-decrement
++id  –-id	Variable pre-increment and pre-decrement
expr ? expr1 : expr2	Conditional operator
expr1 , expr2	Comma
The modulo operator, %, returns the remainder after division:
$ sa "$(( 13 % 5 ))"
:3:
Converting seconds (which is how Unix systems store times) to days, hours, minutes, and seconds involves division and the modulo operator, as shown in Listing 4-2.
Listing 4-2. secs2dhms, Convert Seconds (in Argument $1) to Days, Hours, Minutes, and Seconds
secs_in_day=86400
secs_in_hour=3600
mins_in_hour=60
secs_in_min=60

days=$(( $1 / $secs_in_day ))
secs=$(( $1 % $secs_in_day ))
printf "%d:%02d:%02d:%02d\n" "$days" "$(($secs / $secs_in_hour))" \
        "$((($secs / $mins_in_hour) %$mins_in_hour))" "$(($secs % $secs_in_min))"
If not enclosed in double quotes, the results of arithmetic expansion are subject to word splitting.
Command Substitution
Command substitution replaces a command with its output. The command must be placed either between backticks (` command `) or between parentheses preceded by a dollar sign ($( command ) ). For example, to count the lines in a file whose name includes today’s date, this command uses the output of the date command:
$ wc -l $( date +%Y-%m-%d ).log
61 2009-03-31.log
The old format for command substitution uses backticks. This command is the same as the previous one:
$ wc -l `date +%Y-%m-%d`.log
2 2009-04-01.log
Well, it’s not exactly the same, because I ran the first command shortly before midnight and the second shortly after. As a result, wc processed two different files.
If the command substitution is not quoted, word splitting and pathname expansion are performed on the results.
Word Splitting
The results of parameter and arithmetic expansions, as well as command substitution, are subjected to word splitting if they were not quoted:

$ var="this is a multi-word value"
$ sa $var "$var"
:this:
:is:
:a:
:multi-word:
:value:
:this is a multi-word value:
Word splitting is based on the value of the internal field separator variable, IFS. The default value of IFS contains the whitespace characters of space, tab, and newline (IFS=$' \t\n'). When IFS has its default value or is unset, any sequence of default IFS characters is read as a single delimiter.
$ var='   spaced
   out   '
$ sa $var
:spaced:
:out:
If IFS contains another character (or characters) as well as whitespace, then any sequence of whitespace characters plus that character will delimit a field, but every instance of a non whitespace character delimits a field:
S IFS=' :'
$ var="qwerty  : uiop :  :: er " ## :  :: delimits 2 empty fields
$ sa $var
:qwerty:
:uiop:
::
::
:er:
If IFS contains only non whitespace characters, then every occurrence of every character in IFS delimits a field, and whitespace is preserved:
$ IFS=:
$ var="qwerty  : uiop :  :: er "
$ sa $var
:qwerty  :
: uiop :
:  :
::
: er :
Pathname Expansion
Unquoted words on the command line containing the characters *, ?, and [ are treated as file globbing patterns and are replaced by an alphabetical list of files that match the pattern. If no files match the pattern, the word is left unchanged.
The asterisk matches any string. h* matches all files in the current directory that begin with h, and *k matches all files that end with k. The shell replaces the wildcard pattern with the list of matching files in alphabetical order. If there are no matching files, the wildcard pattern is left unchanged.
$ cd "$HOME/bin"
$ sa h*
:hello:
:hw:
$ sa *k
:incheck:
:numcheck:
:rangecheck:
A question mark matches any single character; the following pattern matches all files whose second letter is a:
$ sa ?a*
:rangecheck:
:ba:
:valint:
:valnum:
Square brackets match any one of the enclosed characters, which may be a list, a range, or a class of characters: [aceg] matches any one of a, c, e, or g; [h-o] matches any character from h to o inclusive; and [[:lower:]] matches all lowercase letters.
You can disable filename expansion with the set -f command. bash has a number of options that affect filename expansion. I’ll cover them in detail in Chapter 8.
Process Substitution
Process substitution creates a temporary filename for a command or list of commands. You can use it anywhere a file name is expected. The form <(command) makes the output of command available as a file name; >(command) is a file name that can be written to.
$ sa <(ls -l) >(pr -Tn)
:/dev/fd/63:
:/dev/fd/62:
  Note  The pr command converts text files for printing by inserting page headers. The headers can be turned off with the -T option, and the -n option numbers the lines.
When the filename on the command line is read, it produces the output of the command. Process substitution can be used in place of a pipeline, allowing variables defined within a loop to be visible to the rest of the script. In this snippet, totalsize is not available to the script outside the loop:
$ ls -l |
> while read perms links owner group size month day time file
> do
>   printf "%10d %s\n" "$size" "$file"
>   totalsize=$(( ${totalsize:=0} + ${size:-0} ))
> done
$  echo ${totalsize-unset} ## print "unset" if variable is not set
unset
By using process substitution instead, the variable totalsize becomes available outside of the loop:
$ while read perms links owner group size month day time file
> do
>   printf "%10d %s\n" "$size" "$file"
>   totalsize=$(( ${totalsize:=0} + ${size:-0} ))
> done < <(ls -l *)
$ echo ${totalsize-unset}
12879
Parsing Options
The options to a shell script, single characters preceded by a hyphen, can be parsed with the builtin command getopts. There may be arguments to some options, and options must precede non option arguments.
Multiple options may be concatenated with a single hyphen, but any that take an argument must be the final option in the string. Its argument follows, with or without intervening whitespace.
On the following command line, there are two options, -a and -f. The latter takes a file name argument. John is the first non option argument, and -x is not an option because it comes after a non option argument.
myscript -a -f filename John -x Jane
The syntax for getopts is as follows:
getopts OPTSTRING var
The OPTSTRING contains all the option’s characters; those that take arguments are followed by a colon. For the script in Listing 4-3, the string is f:v. Each option is placed in the variable $var, and the option’s argument, if any, is placed in $OPTARG.
Usually used as the condition to a while loop, getopts returns successfully until it has parsed all the options on the command line or until it encounters the word --. All remaining words on the command line are arguments passed to the main part of the script.
A frequently used option is -v to turn on verbose mode, which displays more than the default information about the running of the script. Other options—for example, -f—require a file name argument.
This sample script processes both the -v and -f options and, when in verbose mode, displays some information.
Listing 4-3. parseopts, Parse Command-Line Options
progname=${0##*/} ## Get the name of the script without its path

## Default values
verbose=0
filename=

## List of options the program will accept;
## those options that take arguments are followed by a colon
optstring=f:v

## The loop calls getopts until there are no more options on the command line
## Each option is stored in $opt, any option arguments are stored in OPTARG
while getopts $optstring opt
do
  case $opt in
    f) filename=$OPTARG ;; ## $OPTARG contains the argument to the option
    v) verbose=$(( $verbose + 1 )) ;;
    *) exit 1 ;;
  esac
done

## Remove options from the command line
## $OPTIND points to the next, unparsed argument
shift "$(( $OPTIND - 1 ))"

## Check whether a filename was entered
if [ -n "$filename" ]
then
   if [ $verbose -gt 0 ]
   then
      printf "Filename is %s\n" "$filename"
   fi
else
   if [ $verbose -gt 0 ]
   then
     printf "No filename entered\n" >&2
   fi
   exit 1
fi

## Check whether file exists
if [ -f "$filename" ]
then
  if [ $verbose -gt 0 ]
  then
    printf "Filename %s found\n" "$filename"
  fi
else
  if [ $verbose -gt 0 ]
  then
    printf "File, %s, does not exist\n" "$filename" >&2
  fi
  exit 2
fi

## If the verbose option is selected,
## print the number of arguments remaining on the command line
if [ $verbose -gt 0 ]
then
  printf "Number of arguments is %d\n" "$#"
fi
Running the script without any arguments does nothing except generate a failing return code:
$ parseopts
$ echo $?
1
With the verbose option, it prints an error message as well:
$ parseopts -v
No filename entered
$ echo $?
1
With an illegal option (that is, one that is not in $optstring), the shell prints an error message:
$ parseopts -x
/home/chris/bin/parseopts: illegal option – x
If a file name is entered and the file doesn’t exist, it produces this:
$ parseopts -vf qwerty; echo $?
Filename is qwerty
File, qwerty, does not exist
2
To allow a non option argument to begin with a hyphen, the options can be explicitly ended with --:
$ parseopts -vf ~/.bashrc -– -x
Filename is /home/chris/.bashrc
Filename /home/chris/.bashrc found
Number of arguments is 1
Summary
The shell’s preprocessing of the command line before passing it to a command saves the programmer a great deal of work.
Commands
   + head: Extracts the first N lines from a file; N defaults to 10
   + cut: Extracts columns from a file
Exercises
1.	How many arguments are there on this command line?
sa $# $(date "+%Y %m %d") John\ Doe
2.	What potential problem exists with the following snippet?
year=$( date +%Y )
month=$( date +%m )
day=$( date +%d )
hour=$( date +%H )
minute=$( date +%M )
second=$( date +%S )
