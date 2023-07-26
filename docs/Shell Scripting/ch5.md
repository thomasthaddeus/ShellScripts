CHAPTER 5

Parameters and Variables
Variables have been part of the Unix shell since its inception more than 30 years ago, but their features have grown over the years. The standard Unix shell now has parameter expansions that perform sophisticated manipulations on their contents. bash adds even more expansion capabilities as well as indexed and associative arrays.
This chapter covers what you can do with variables and parameters, including their scope. In other words, after a variable has been defined, where can its value be accessed? This chapter gives a glimpse of the more than 80 variables used by the shell that are available to the programmer. It discusses how to name your variables and how to pick them apart with parameter expansion.
Positional parameters are the arguments passed to a script. They can be manipulated with the shift command and used individually by number or in a loop.
Arrays assign more than one value to a name. bash has both numerically indexed arrays and, beginning with bash-4.0, associative arrays that are assigned and referenced by a string instead of a number.
The Naming of Variables
Variable names can contain only letters, numbers, and underscores, and they must start with a letter or an underscore. Apart from those restrictions, you are free to build your names as you see fit. It is, however, a good idea to use a consistent scheme for naming variables, and choosing meaningful names can go a long way toward making your code self-documenting.
Perhaps the most frequently cited (though less often implemented) convention is that environment variables should be in capital letters, while local variables should be in lowercase. Given that bash itself uses more than 80 uppercase variables internally, this is a dangerous practice, and conflicts are not uncommon. I have seen variables such as PATH, HOME, LINES, SECONDS, and UID misused with potentially disastrous consequences. None of bash’s variables begin with an underscore, so in my first book, Shell Scripting Recipes: A Problem-Solution Approach (Apress, 2005), I used uppercase names preceded by an underscore for values set by shell functions.
Single-letter names should be used rarely. They are appropriate as the index in a loop, where its sole function is as a counter. The letter traditionally used for this purpose is i, but I prefer n. (When teaching programming in a classroom, the letter I on the blackboard was too easily confused with the number 1, so I started using n for “number,” and I still use it 25 years later).
The only other place I use single-letter variable names is when reading throwaway material from a file. If I need only one or two fields from a file, for example, I might use this:
while IFS=: read login a b c name e
do
  printf "%-12s %s\n" "$login" "$name"
done < /etc/passwd
I recommend using either of two naming schemes. The first is used by Heiner Steven on his Shelldorado web site at http://www.shelldorado.com/. He capitalizes the first letter of all variables and also the first letters of further words in the name: ConfigFile, LastDir, FastMath. In some cases, his usage is closer to mine.
I use all lowercase letters: configfile, lastdir, fastmath. When the run-together words are ambiguous or hard to read, I separate them with an underscore: line_width, bg_underline, day_of_week.
Whatever system you choose, the important thing is that the names give a real indication of what the variable contains. But don't get carried away and use something like this:
long_variable_name_which_may_tell_you_something_about_its_purpose=1
The Scope of a Variable: Can You See It from Here?
By default, a variable’s definition is known only to the shell in which it is defined (and to subshells of that shell). The script that called the current script will not know about it, and a script called by the current script will not know about the variable unless it is exported to the environment.
The environment is an array of strings of the form name=value. Whenever an external command is executed (creating a child process), whether it is a compiled, binary command or an interpreted script, this array is passed to it behind the scenes. In a shell script, these strings are available as variables.
Variables assigned in a script may be exported to the environment using the shell builtin command export:
var=whatever
export var
In bash this may be abbreviated like this:
export var=whatever
There is no need to export a variable unless you want to make it available to scripts (or other programs) called from the current script (and their children and their children’s children and...). Exporting a variable doesn’t make it visible anywhere except child processes.
Listing 5-1 tells you whether the variable $x is in the environment and what it contains, if anything.
Listing 5-1. showvar, Print Value of Variable x
if [[ ${x+X} = X ]] ## If $x is set
then
  if [[ -n $x ]] ## if $x is not empty
  then
    printf "  \$x = %s\n" "$x"
  else
    printf "  \$x is set but empty\n"
  fi
else
  printf " %s is not set\n" "\$x"
fi
Once a variable is exported, it remains in the environment until it is unset:
$ unset x
$ showvar
  $x is not set
$ x=3
$ showvar
  $x is not set
$ export x
$ showvar
  $x = 3
$ x= ## in bash, reassignment doesn't remove a variable from the environment
$ showvar
  $x is set but empty
  Note  showvar is not a bash command, but a script as seen in Listing 5-1 that works with the value of x.
Variables set in a subshell are not visible to the script that called it. Subshells include command substitution, as in $(command) or `command`; all elements of a pipeline, and code enclosed in parentheses, as in ( command ).
Probably the most frequently asked question about shell programming is, “Where did my variables go? I know I set them, so why are they empty?” More often than not, this is caused by piping the output of one command into a loop that assigns variables:
printf "%s\n" ${RANDOM}{,,,,,} |
  while read num
  do
    (( num > ${biggest:=0} )) && biggest=$num
  done
printf "The largest number is: %d\n" "$biggest"
When biggest is found to be empty, complaints of variables set in while loops not being available outside them are heard in all the shell forums. But the problem is not the loop; it is that the loop is part of a pipeline and therefore is being executed in a subshell.
With bash-4.2, a new option, lastpipe, enables the last process in a pipeline to be executed in the current shell. It is invoked with the following:
shopt -s lastpipe
Shell Variables
The shell either sets or uses more than 80 variables. Many of these are used by bash internally and are of little use to shell programmers. Others are used in debugging, and some are in common use in shell programs. About half are set by the shell itself, and the rest are set by the operating system, the user, the terminal, or a script.
Of those set by the shell, you have already looked at RANDOM, which returns a random integer between 0 and 32,767, and PWD, which contains the path to the current working directory. You saw OPTIND and OPTARG used in parsing command-line options (chapter 4). Sometimes, BASH_VERSION (or BASH_VERSINFO) is used to determine whether the running shell is capable of running a script. Some of the scripts in this book require at least bash-3.0 and might use one of those variables to determine whether the current shell is recent enough to run the script:
case $BASH_VERSION in
  [12].*) echo "You need at least bash3.0 to run this script" >&2; exit 2;;
esac
The prompt string variables, PS1 and PS2, are used in interactive shells at the command line; PS3 is used with the select builtin command, and PS4 is printed before each line in execution trace mode (more on that in chapter 10).
SHELL VARIABLES
The following variables are set by the shell:

The following variables are used by the shell, which may set a default value for some of them (for example, IFS):
See Appendix A for a description of all the shell variables.
Parameter Expansion
Much of the power of the modern Unix shell comes from its parameter expansions. In the Bourne shell, these mostly involved testing whether a parameter is set or empty and replacing with a default or alternate value. KornShell additions, which were incorporated into the POSIX standard, added string manipulation. KornShell 93 added more expansions that have not been incorporated into the standard but that bash has adopted. bash-4.0 has added two new expansions of its own.
Bourne Shell
The Bourne shell and its successors have expansions to replace an empty or unset variable with a default, to assign a default value to a variable if it is empty or unset, and to halt execution and print an error message if a variable is empty or unset.
${var:-default} and ${var-default}: Use Default Values
The most commonly used expansion, ${var:-default}, checks to see whether a variable is unset or empty and expands to a default string if it is:
$ var=
$ sa "${var:-default}"  ## The sa script was introduced in Chapter 4
:default:
If the colon is omitted, the expansion checks only whether the variable is unset:
$ var=
$ sa "${var-default}" ## var is set, so expands to nothing
::
$ unset var
$ sa "${var-default}" ## var is unset, so expands to "default"
:default:
This snippet assigns a default value to $filename if it is not supplied by an option or inherited in the environment:
defaultfile=$HOME/.bashrc
## parse options here
filename=${filename:-"$defaultfile"}
${var:+alternate}, ${var+alternate}: Use Alternate Values
The complement to the previous expansion substitutes an alternate value if the parameter is not empty or, without a colon, if it is set. The first expansion will use alternate only if $var is set and is not empty:
$ var=
$ sa "${var:+alternate}" ## $var is set but empty
::
$ var=value
$ sa "${var:+alternate}" ## $var is not empty
:alernate:
Without the colon, alternate is used if the variable is set, even if it is empty:
$ var=
$ sa "${var+alternate}" ## var is set
:altername:
$ unset var
$ sa "${var+alternate}" ## $var is not set
::
$ var=value
$ sa "${var:+alternate}" ## $var is set and not empty
:alternate:
This expansion is often used when adding strings to a variable. If the variable is empty, you don’t want to add a separator:
$ var=
$ for n in a b c d e f g
> do
>   var="$var $n"
> done
$ sa "$var"
: a b c d e f g:
To prevent the leading space, you can use parameter expansion:
$ var=
$ for n in a b c d e f g
> do
>   var="${var:+"$var "}$n"
> done
$ sa "$var"
:a b c d e f g:
That is a shorthand method of doing the following for each value of n:
if [ -n "$var" ]
then
  var="$var $n"
else
  var=$n
fi
or:
[ -n "$var" ] && var="$var $n" || var=$n
${var:=default}, ${var=default}: Assign Default Values
The ${var:=default} expansion behaves in the same way as ${var:-default} except that it also assigns the default value to the variable:
$ unset n
$ while :
> do
>  echo :$n:
>  [ ${n:=0} -gt 3 ] && break ## set $n to 0 if unset or empty
>  n=$(( $n + 1 ))
> done
::
:1:
:2:
:3:
:4:
${var:?message}, ${var?message}: Display Error Message If Empty or Unset
If var is empty or not set, message will be printed to the standard error, and the script will exit with a status of 1. If message is empty, parameter null or not set will be printed. Listing 5-2 expects two non-null command-line arguments and uses this expansion to display error messages when they are missing or null.
Listing 5-2. checkarg, Exit If Parameters Are Unset or Empty
## Check for unset arguments
: ${1?An argument is required} \
  ${2?Two arguments are required}

## Check for empty arguments
: ${1:?A non-empty argument is required} \
  ${2:?Two non-empty arguments are required}

echo "Thank you."
The message will be printed by the first expansion that fails, and the script will exit at that point:
$ checkarg
/home/chris/bin/checkarg: line 10: 1: An argument is required
$ checkarg x
/home/chris/bin/checkarg: line 10: 2: Two arguments are required
$ checkarg '' ''
/home/chris/bin/checkarg: line 13: 1: A non-empty argument is required
$ checkarg x ''
/home/chris/bin/checkarg: line 13: 2: Two non-empty arguments are required
$ checkarg x x
Thank you.
POSIX Shell
Besides the expansions from the Bourne shell, the POSIX shell includes a number of expansions from the KornShell. These include returning the length and removing a pattern from the beginning or end of a variable’s contents.
${#var}: Length of Variable’s Contents
This expansion returns the length of the expanded value of the variable:
read passwd
if [ ${#passwd} -lt 8 ]
then
  printf "Password is too short: %d characters\n" "$#" >&2
  exit 1
fi
${var%PATTERN}: Remove the Shortest Match from the End
The variable is expanded, and the shortest string that matches PATTERN is removed from the end of the expanded value. The PATTERN here and in other parameter expansions is a filename expansion (aka file globbing) pattern.
Given the string Toronto and the pattern o*, the shortest matching pattern is the final o:
$ var=Toronto
$ var=${var%o*}
$ printf "%s\n" "$var"
Toront
Because the truncated string has been assigned to var, the shortest string that now matches the pattern is ont:
$ printf "%s\n" "${var%o*}"
Tor
This expansion can be used to replace the external command, dirname, which strips the filename portion of a path, leaving the path to the directory (Listing 5-3). If there is no slash in the string, the current directory is printed if it is the name of an existing file in the current directory; otherwise, a dot is printed.
Listing 5-3. dname, Print the Directory Portion of a File Path
case $1 in
  */*) printf "%s\n" "${1%/*}" ;;
  *) [ -e "$1" ] && printf "%s\n" "$PWD" || echo '.' ;;
esac
  Note  I have called this script dname rather than dirname because it doesn’t follow the POSIX specification for the dirname command. In the next chapter, there is a shell function called dirname that does implement the POSIX command.
$ dname /etc/passwd
/etc
$ dname bin
/home/chris
${var%%PATTERN}: Remove the Longest Match from the End
The variable is expanded, and the longest string that matches PATTERN from the end of the expanded value is removed:
$ var=Toronto
$ sa "${var%%o*}"
:t:
${var#PATTERN}: Remove the Shortest Match from the Beginning
The variable is expanded, and the shortest string that matches PATTERN is removed from the beginning of the expanded value:
$ var=Toronto
$ sa "${var#*o}"
:ronto:
${var##PATTERN}: Remove the Longest Match from the Beginning
The variable is expanded, and the longest string that matches PATTERN is removed from the beginning of the expanded value. This is often used to extract the name of a script from the $0 parameter, which contains the full path to the script:
scriptname=${0##*/} ## /home/chris/bin/script => script
Bash
Two expansions from KornShell 93 were introduced in bash2: search and replace and substring extraction.
${var//PATTERN/STRING}: Replace All Instances of PATTERN with STRING
Because the question mark matches any single character, this example hides a password:
$ passwd=zxQ1.=+-a
$ printf "%s\n" "${passwd//?/*}"
*********
With a single slash, only the first matching character is replaced.
$ printf "%s\n" "${passwd/[[:punct:]]/*}"
zxQ1*=+-a
${var:OFFSET:LENGTH}: Return a Substring of $var
A substring of $var starting at OFFSET is returned. If LENGTH is specified, that number of characters is substituted; otherwise, the rest of the string is returned. The first character is at offset 0:
$ var=Toronto
$ sa "${var:3:2}"
:on:
$ sa "${var:3}"
:onto:
A negative OFFSET is counted from the end of the string. If a literal minus sign is used (as opposed to one contained in a variable), it must be preceded by a space to prevent it from being interpreted as a default expansion:
$ sa "${var: -3}"
:nto:
${!var}: Indirect Reference
If you have one variable containing the name of another, for example x=yes and a=x, bash can use an indirect reference:
$ x=yes
$ a=x
$ sa "${!a}"
:yes:
The same effect can be had using the eval builtin command, which expands its arguments and executes the resulting string as a command:
$ eval "sa \$$a"
:yes:
See chapter 9 for a more detailed explanation of eval.
Bash-4.0
In version 4.0, bash introduced two new parameter expansions, one for converting to uppercase and one for lowercase. Both have single-character and global versions.
${var^PATTERN}: Convert to Uppercase
The first character of var is converted to uppercase if it matches PATTERN; with a double caret (^^), it converts all characters matching PATTERN. If PATTERN is omitted, all characters are matched:
$ var=toronto
$ sa "${var^}"
:Toronto:
$ sa "${var^[n-z]}"
:Toronto:
$ sa "${var^^[a-m]}" ## matches all characters from a to m inclusive
:toronto:
$ sa "${var^^[n-q]}"
:tOrONtO:
$ sa "${var^^}"
:TORONTO:
${var,PATTERN}: Convert to Lowercase
This expansion works in the same way as the previous one, except that it converts uppercase to lowercase:
$ var=TORONTO
$ sa "${var,,}"
:toronto:
$ sa "${var,,[N-Q]}"
:ToRonTo:There is also an undocumented expansion that inverts the case:
$ var=Toronto
$ sa "${var~}"
:toronto:
$ sa "${var~~}"
:tORONTO:
Positional Parameters
The positional parameters can be referenced individually by number ($1 ... $9 ${10} ...) or all at once with "$@" or "$*". As has already been noted, parameters greater than 9 must be enclosed in braces: ${10}, ${11}.
The shift command without an argument removes the first positional parameter and shifts the remaining arguments forward so that $2 becomes $1, $3 becomes $2, and so on. With an argument, it can remove more. To remove the first three parameters, supply an argument with the number of parameters to remove:
$ shift 3
To remove all the parameters, use the special parameter $#, which contains the number of positional parameters:
$ shift "$#"
To remove all but the last two positional parameters, use this:
$ shift "$(( $# - 2 ))"
To use each parameter in turn, there are two common methods. The first way is to loop through the values of the parameters by expanding "$@":
for param in "$@"  ## or just:  for param
do
  : do something with $param
done
And this is the second:
while (( $# ))
do
  : do something with $1
  shift
done
Arrays
All the variables used so far have been scalar variables; that is, they contain only a single value. In contrast, array variables can contain many values. The POSIX shell does not support arrays, but bash (since version 2) does. Its arrays are one dimensional and indexed by integers, and also, since bash-4.0, with strings.
Integer-Indexed Arrays
The individual members of an array variable are assigned and accessed with a subscript of the form [N]. The first element has an index of 0. In bash, arrays are sparse; they needn’t be assigned with consecutive indices. An array can have an element with an index of 0, another with an index of 42, and no intervening elements.
Displaying Arrays
Array elements are referenced by the name and a subscript in braces. This example will use the shell variable BASH_VERSINFO. It is an array that contains version information for the running shell. The first element is the major version number, the second is the minor:
$ printf "%s\n" "${BASH_VERSINFO[0]}"
4
$ printf "%s\n" "${BASH_VERSINFO[1]}"
3
All the elements of an array can be printed with a single statement. The subscripts @ and * are analogous to their use with the positional parameters: * expands to a single parameter if quoted; if unquoted, word splitting and file name expansion is performed on the result. Using @ as the subscript and quoting the expansion, each element expands to a separate argument, and no further expansion is performed on them.
$ printf "%s\n" "${BASH_VERSINFO[*]}"
4 3 30 1 release i686-pc-linux-gnuoldld
$  printf "%s\n" "${BASH_VERSINFO[@]}"
4
3
30
1
release
i686-pc-linux-gnu
Various parameter expansions work on arrays; for example, to get the second and third elements from an array, use this:
$ printf "%s\n" "${BASH_VERSINFO[@]:1:2}" ## minor version number and patch level
3
30
The length expansion returns the number of elements in the array when the subscript is * or @, and it returns the length of an individual element if a numeric index is given:
$ printf "%s\n" "${#BASH_VERSINFO[*]}"
6
$ printf "%s\n" "${#BASH_VERSINFO[2]}" "${#BASH_VERSINFO[5]}"
2
17
Assigning Array Elements
Elements can be assigned using an index; the following commands create a sparse array:
name[0]=Aaron
name[42]=Adams
Indexed arrays are more useful when elements are assigned consecutively (or packed), because it makes operations on them simpler. Assignments can be made directly to the next unassigned element:
$ unset a
$ a[${#a[@]}]="1 $RANDOM" ## ${#a[@]} is 0
$ a[${#a[@]}]="2 $RANDOM" ## ${#a[@]} is 1
$ a[${#a[@]}]="3 $RANDOM" ## ${#a[@]} is 2
$ a[${#a[@]}]="4 $RANDOM" ## ${#a[@]} is 3
$ printf "%s\n" "${a[@]}"
1 6007
2 3784
3 32330
4 25914
An entire array can be populated with a single command:
$ province=( Quebec Ontario Manitoba )
$ printf "%s\n" "${province[@]}"
Quebec
Ontario
Manitoba
The += operator can be used to append values to the end of an indexed array. This results in a neater form of assignment to the next unassigned element:
$ province+=( Saskatchewan )
$ province+=( Alberta "British Columbia" "Nova Scotia" )
$ printf "%-25s %-25s %s\n" "${province[@]}"
Quebec                    Ontario                   Manitoba
Saskatchewan              Alberta                   British Columbia
Nova Scotia
Associative Arrays
Associative arrays, introduced in bash in version 4.0, use strings as subscripts and must be declared before being used:
$ declare -A array
$ for subscript in a b c d e
> do
>   array[$subscript]="$subscript $RANDOM"
> done
$ printf ":%s:\n" "${array["c"]}" ## print one element
:c 1574:
$ printf ":%s:\n" "${array[@]}" ## print the entire array
:a 13856:
:b 6235:
:c 1574:
:d 14020:
:e 9165:
Summary
By far the largest subject in this chapter is parameter expansion, and by far the largest section of parameter expansion is devoted to those expansions that were introduced by the KornShell and incorporated into the standard Unix shell. These are tools that give the POSIX shell much of its power. The examples given in this chapter are relatively simple; the full potential of parameter expansion will be shown as you develop serious programs later in the book.
Next in importance are arrays. Though not part of the POSIX standard, they add a great deal of functionality to the shell by making it possible to collect data in logical units.
Understanding the scope of variables can save a lot of head scratching, and well-named variables make a program more understandable and maintainable.
Manipulating the positional parameters is a minor but important aspect of shell programming, and the examples given in this chapter will be revisited and expanded upon later in the book.
Commands
   + declare: Declares variables and sets their attributes
   + eval: Expands arguments and executes the resulting command
   + export: Places variables into the environment so that they are available to child processes
   + shift: Deletes and renumbers positional parameters
   + shopt: Sets shell options
   + unset: Removes a variable entirely
Concepts
   + Environment: A collection of variables inherited from the calling program and passed to child processes
   + Array variables: Variables that contain more than one value and accessed using a subscript
   + Scalar variables: Variables that contain a single value
   + Associative arrays: Array variables whose subscript is a string rather than an integer

#### EXERCISES

   1. By default, where can a variable assigned in a script be accessed? Select all that apply:
       + In the current script
       + In functions defined in the current script
       + In the script that called the current script
       + In scripts called by the current script
       + In subshells of the current script
   2. I advise against using single-letter variables names but give a couple of places where they are reasonable. Can you think of any other legitimate uses for them?
   3. Given var=192.168.0.123, write a script that uses parameter expansion to extract the second number, 168.
