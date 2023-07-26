
## CHAPTER 6

### Shell Functions

A shell function is a compound command that has been given a name. It stores a series of commands for later execution. The name becomes a command in its own right and can be used in the same way as any other command. Its arguments are available in the positional parameters, just as in any other script. Like other commands, it sets a return code.
A function is executed in the same process as the script that calls it. This makes it fast, because no new process has to be created. All the variables of the script are available to it without having to be exported, and when a function changes those variables, the changes will be seen by the calling script. That said, you can make variables local to the function so that they do not affect the calling script; the choice is yours.
Not only do functions encapsulate code for reuse in a single script, but they can make it available to other scripts. They make top-down design easy, and improve legibility. They break scripts into manageable chunks that can be tested and debugged separately.
At the command line, functions can do things that an external script cannot, such as change directories. They are much more flexible and powerful than aliases, which simply replace the command you type with a different command. Chapter 11 presents a number of functions that make working at the prompt more productive.
Definition Syntax
When shell functions were introduced in the KornShell, the definition syntax was as follows:
function name <compound command>
When the Bourne shell added functions in 1984, the syntax (which was later included in ksh and adopted by the POSIX standard) was as follows:
name() <compound command>
bash allows either syntax as well as the hybrid:
function name() <compound command>
The following is a function that I wrote several years ago and that, I recently discovered, is included as an example in the bash source code package. It checks whether a dotted-quad Internet Protocol (IP) address is valid. In this book, we always use the POSIX syntax for function definition:
isvalidip()
Then the body of the function is enclosed in braces ({ ... }) followed by optional redirection (see the uinfo function later in this chapter for an example).
The first set of tests is contained in a case statement:
case $1 in
  "" | *[!0-9.]* | *[!0-9]) return 1 ;;
esac
It checks for an empty string, invalid characters, or an address that doesn’t end with a digit. If any of these items is found, the shell built in command return is invoked with an exit status of 1. This exits the function and returns control to the calling script. An argument sets the function’s return code; if there is no argument, the exit code of the function defaults to that of the last command executed.
The next command, local, is a shell built in that restricts a variable’s scope to the function (and its children), but the variable will not change in the parent process. Setting IFS to a period causes word splitting at periods, rather than whitepace, when a parameter is expanded. Beginning with bash-4.0, local and declare have an option, -A, to declare an associative array.
local IFS=.
The set builtin replaces the positional parameters with its arguments. Since $IFS is a period, each element of the IP address is assigned to a different parameter.
set -- $1
The final two lines check each positional parameter in turn. If it’s greater than 255, it is not valid in a dotted-quad IP address. If a parameter is empty, it is replaced with the invalid value of 666. If all tests are successful, the function exits successfully; if not, the return code is 1, or failure.
[ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] &&
[ ${3:-666} -le 255 ] && [ ${4:-666} -le 255 ]
Listing 6-1 shows the complete function with comments.
Listing 6-1. isvalidip, Check Argument for Valid Dotted-Quad IP Address
isvalidip() #@ USAGE: isvalidip DOTTED-QUAD
{
  case $1 in
    ## reject the following:
    ##   empty string
    ##   anything other than digits and dots
    ##   anything not ending in a digit
    "" | *[!0-9.]* | *[!0-9]) return 1 ;;
  esac

  ## Change IFS to a dot, but only in this function
  local IFS=.

  ## Place the IP address into the positional parameters;
  ## after word splitting each element becomes a parameter
  set -- $1

  [ $# -eq 4 ] && ## must be four parameters
                  ## each must be less than 256
  ## A default of 666 (which is invalid) is used if a parameter is empty
  ## All four parameters must pass the test
  [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] &&
  [ ${3:-666} -le 255 ] && [ ${4:-666} -le 255 ]
}
  Note  Formats other than dotted quads can be valid IP addresses, as in 127.1, 216.239.10085, and 3639551845.
The function returns successfully (that is, a return code of 0) if the argument supplied on the command line is a valid dotted-quad IP address. You can test the function at the command line by sourcing the file containing the function:

```sh
$ . isvalidip-func
The function is now available at the shell prompt. Let’s test it with a few IP addresses:
$ for ip in 127.0.0.1 168.260.0.234 1.2.3.4 123.1OO.34.21 204.225.122.150
> do
>   if isvalidip "$ip"
>   then
>     printf "%15s: valid\n" "$ip"
>   else
>     printf "%15s: invalid\n" "$ip"
>   fi
> done
      127.0.0.1: valid
  168.260.0.234: invalid
        1.2.3.4: valid
  123.1OO.34.21: invalid
204.225.122.150: valid
```

### Compound Commands
A compound command is a list of commands enclosed in ( ... ) or { ... }, expressions enclosed in (( ... )) or [[ ... ]], or one of the block-level shell keywords (that is, case, for, select, while, and until).
The valint program from Chapter 3 is a good candidate for converting to a function. It is likely to be called more than once, so the time saved could be significant. The program is a single compound command, so braces are not necessary (see Listing 6-2).
Listing 6-2. valint, Check for Valid Integer
valint() #@ USAGE: valint INTEGER
  case ${1#-} in      ## Leading hyphen removed to accept negative numbers
    *[!0-9]*) false;; ## the string contains a non-digit character
    *) true ;;        ## the whole number, and nothing but the number
  esac
If a function’s body is wrapped in parentheses, then it is executed in a subshell, and changes made during its execution do not remain in effect after it exits:
$ funky() ( name=nobody; echo "name = $name" )
$ name=Rumpelstiltskin
$ funky
name = nobody
$ echo "name = $name"
name = Rumpelstiltskin
Getting Results
The two previous functions are both called for their exit status; the calling program needs to know only whether the function succeeds or fails. Functions can also return information from a range of return codes, by setting one or more variables or by printing its results.
Set Different Exit Codes
You can convert the rangecheck script from Chapter 3 to a function with a couple of improvements; it returns 0 on success as before but differentiates between a number that is too high and one that is too low. It returns 1 if the number is too low, or it returns 2 if it is too high. It also accepts the range to be checked as arguments on the command line, defaulting to 10 and 20 if no range is given (Listing 6-3).
Listing 6-3. rangecheck, Check Whether an Integer Is Within a Specified Range
rangecheck() #@ USAGE: rangecheck int [low [high]]
  if [ "$1" -lt ${2:-10} ]
  then
    return 1
  elif [ "$1" -gt ${3:-20} ]
  then
    return 2
  else
    return 0
  fi
Return codes are a single, unsigned byte; therefore, their range is 0 to 255. If you need numbers larger than 255 or less than 0, use one of the other methods of returning a value.
Print the Result
A function’s purpose may be to print information, either to the terminal or to a file (Listing 6-4).
Listing 6-4. uinfo, Print Information About the Environment
uinfo() #@ USAGE: uinfo [file]
{
  printf "%12s: %s\n" \
    USER    "${USER:-No value assigned}" \
    PWD     "${PWD:-No value assigned}" \
    COLUMNS "${COLUMNS:-No value assigned}" \
    LINES   "${LINES:-No value assigned}" \
    SHELL   "${SHELL:-No value assigned}" \
    HOME    "${HOME:-No value assigned}" \
    TERM    "${TERM:-No value assigned}"
} > ${1:-/dev/fd/1}
The redirection is evaluated at runtime. In this example, it expands to the function’s first argument or to /dev/fd/1 (standard output) if no argument is given:
$ uinfo
        USER: chris
         PWD: /home/chris/work/BashProgramming
     COLUMNS: 100
       LINES: 43
       SHELL: /bin/bash
        HOME: /home/chris
        TERM: rxvt
$ cd; uinfo $HOME/tmp/info
$ cat $HOME/tmp/info
        USER: chris
         PWD: /home/chris
     COLUMNS: 100
       LINES: 43
       SHELL: /bin/bash
        HOME: /home/chris
              TERM: rxvt
When the output is printed to the standard output, it may be captured using command substitution:
info=$( uinfo )
But command substitution creates a new process and is therefore slow; save it for use with external commands. When a script needs output from a function, put it into variables.
Place Results in One or More Variables
I was writing a script that needed to sort three integers from lowest to highest. I didn’t want to call an external command for a maximum of three comparisons, so I wrote the function shown in Listing 6-5. It stores the results in three variables: _MIN3, _MID3, and _MAX3.
Listing 6-5. _max3, Sort Three Integers
_max3() #@ Sort 3 integers and store in $_MAX3, $_MID3 and $_MIN3
{       #@ USAGE:
    [ $# -ne 3  ] && return 5
    [ $1 -gt $2 ] && { set -- $2 $1 $3; }
    [ $2 -gt $3 ] && { set -- $1 $3 $2; }
    [ $1 -gt $2 ] && { set -- $2 $1 $3; }
    _MAX3=$3
    _MID3=$2
    _MIN3=$1
}
In the first edition of this book, I used the convention of beginning function names with an underscore when they set a variable rather than print the result. The variable is the name of the function converted to uppercase. In this instance, I needed two other variables as well.
I could have used an array instead of three variables:
_MAX3=( "$3" "$2" "$1" )
These days, I usually pass the name of a variable to store the result. The nameref property, introduced in bash-4.x, makes this easy to use:
max3() #@ Sort 3 integers and store in an array
{      #@ USAGE: max3 N1 N2 N3 [VARNAME]
  declare -n _max3=${4:-_MAX3}
  (( $# < 3 )) && return 4
  (( $1 > $2 )) && set -- "$2" "$1" "$3"
  (( $2 > $3 )) && set -- "$1" "$3" "$2"
  (( $1 > $2 )) && set -- "$2" "$1" "$3"
  _max3=( "$3" "$2" "$1" )
}
If no variable name is supplied on the command line, _MAX3 is used.
Function Libraries
In my scripts directory, I have about 100 files of nothing but functions. A few contain only a single function, but most are collections of functions with a common theme. Sourcing one of these files defines a number of related functions that can be used in the current script.
I have a library of functions for manipulating dates and another for dissecting strings. I have one for creating PostScript files of chess diagrams and one for playing with crossword puzzles. There’s a library for reading function keys and cursor keys and a different one for mouse buttons.
Using Functions from Libraries
Most of the time, I source the library to include all its functions in my script:
. date-funcs ## get date-funcs from:
             ## http://cfaj.freeshell.org/shell/ssr/08-The-Dating-Game.shtml
Occasionally, I need only one function from a library, so I cut and paste it into the new script.
Sample Script
The following script defines four functions: die, usage, version, and readline. The readline function will differ according to which shell you are using. The script creates a basic web page, complete with title and primary headline (<H1>). The readline function uses options to the builtin command read that will be examined in detail in Chapter 9.

```sh
##
## Set defaults
##
prompt=" ==> "
template='<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset=utf-8>
    <title>%s</title>
    <link href="%s" rel="stylesheet">
  </head>
  <body>
    <h1>%s</h1>
    <div id=main>

    </div>
  </body>
</html>
'

##
## Define shell functions
##
die() #@ DESCRIPTION: Print error message and exit with ERRNO code
{     #@ USAGE: die ERRNO MESSAGE ...
  error=$1
  shift
  [ -n "$*" ] && printf "%s\n" "$*" >&2
  exit "$error"
}

usage() #@ Print script's usage information
{       #@ USAGE: usage
  printf "USAGE: %s HTMLFILE\n" "$progname"
}

version() #@ Print scrpt's version information
{          #@ USAGE: version
  printf "%s version %s" "$progname" "${version:-1}"
}

#@ USAGE: readline var prompt default
#@ DESCRIPTION: Prompt user for string and offer default
##
#@ Define correct version for your version of bash or other shell
bashversion=${BASH_VERSION%%.*}
if [ ${bashversion:-0} -ge 4 ]
then
  ## bash4.x has an -i option for editing a supplied value
  readline()
  {
    read -ep "${2:-"$prompt"}" -i "$3" "$1"
  }
elif [ ${BASHVERSION:-0} -ge 2 ]
then
  readline()
  {
    history -s "$3"
    printf "Press up arrow to edit default value: '%s'\n" "${3:-none}"
    read -ep "${2:-"$prompt"}" "$1"
  }
else
  readline()
  {
    printf "Press enter for default of '%s'\n" "$3"
    printf "%s " "${2:-"$prompt"}"
    read
    eval "$1=\${REPLY:-"$3"}"
  }
fi

if [ $# -ne 1 ]
then
  usage
  exit 1
fi

filename=$1

readline title "Page title: "
readline h1 "Main headline: " "$title"
readline css "Style sheet file: " "${filename%.*}.css"

printf "$template" "$title" "$css" "$h1" > "$filename"
```

### Summary

Shell functions enable you to create large, fast, sophisticated programs. Without them, the shell could hardly be called a real programming language. Functions will be part of almost everything from here to the end of the book.

#### Commands

   + local: Restricts a variable’s scope to the current function and its children
   + return: Exits a function (with an optional return code)
   + set: With --, replaces the positional parameters with the remaining arguments (after --)

#### Exercises

1. Rewrite function isvalidip using parameter expansion instead of changing IFS.
2. Add a check to max3 to verify that VARNAME is a valid name for a variable.
