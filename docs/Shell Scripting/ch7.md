## CHAPTER 7

String Manipulation
In the Bourne shell, very little string manipulation was possible without resorting to external commands. Strings could be concatenated by juxtaposition, they could be split by changing the value of IFS, and they could be searched with case, but anything else required an external command.
Even things that could be done entirely in the shell were often relegated to external commands, and that practice has continued to this day. In some current Linux distributions, you can find the following snippet in /etc/profile. It checks whether a directory is included in the PATH variable:
if ! echo ${PATH} |grep -q /usr/games
then
  PATH=$PATH:/usr/games
fi
Even in a Bourne shell, you can do this without an external command:
case :$PATH: in
  *:/usr/games:*);;
  *) PATH=$PATH:/usr/games ;;
esac
The POSIX shell includes a number of parameter expansions that slice and dice strings, and bash adds even more. These were outlined in Chapter 5, and their use is expanded upon in this chapter along with other string techniques.
Concatenation
Concatenation is the joining together of two or more items to form one larger item. In this case, the items are strings. They are joined by placing one after the other. A common example, which is used in Chapter 1, adds a directory to the PATH variable. It concatenates a variable with a single-character string (:), another variable, and a literal string:
PATH=$PATH:$HOME/bin
If the right side of the assignment contains a literal space or other character special to the shell, then it must be quoted with double quotes (variables inside single quotes are not expanded):
var=$HOME/bin # this comment is not part of the assignment
var="$HOME/bin # but this is"
In bash-3.1, a string append operator (+=) was added:
$ var=abc
$ var+=xyz
$ echo "$var"
abcxyz
This append operator += looks much better and is clearer to understand. It also has a slight performance advantage over the other method. It also makes sense to use += for appending to an array, as demonstrated in Chapter 5.
  Tip  For those that want to benchmark the two methods, you could try this little one liner var=; time for i in {1..1000};do var=${var}foo;done;var=; time for i in {1..1000};do var+=foo;done
Repeat Character to a Given Length
Concatenation is used in this function that builds a string of N characters; it loops, adding one instance of $1 each time, until the string ($_REPEAT) reaches the desired length (contained in $2).
_repeat()
{
  #@ USAGE: _repeat string number
  _REPEAT=
  while (( ${#_REPEAT} < $2 ))
  do
    _REPEAT=$_REPEAT$1
  done
}
The result is stored in the variable _REPEAT:
$ _repeat % 40
$ printf "%s\n" "$_REPEAT"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
You can speed that function up by concatenating more than one instance in each loop so that the length increases geometrically. The problem with this version is that the resulting string will usually be longer than required. To fix that, parameter expansion is used to trim the string to the desired length (Listing 7-1).
Listing 7-1. repeat, Repeat a String N Times
_repeat()
{
  #@ USAGE: _repeat string number
  _REPEAT=$1
  while (( ${#_REPEAT} < $2 )) ## Loop until string exceeds desired length
  do
    _REPEAT=$_REPEAT$_REPEAT$_REPEAT ## 3 seems to be the optimum number
  done
  _REPEAT=${_REPEAT:0:$2} ## Trim to desired length
}

repeat()
{
  _repeat "$@"
  printf "%s\n" "$_REPEAT"
}
The _repeat function is called by the alert function (Listing 7-2).
Listing 7-2. alert, Print a Warning Message with a Border and a Beep
alert() #@ USAGE: alert message border
{
  _repeat "${2:-#}" $(( ${#1} + 8 ))
  printf '\a%s\n' "$_REPEAT" ## \a = BEL
  printf '%2.2s  %s  %2.2s\n' "$_REPEAT" "$1" "$_REPEAT"
  printf '%s\n' "$_REPEAT"
}
The function prints the message surrounded by a border generated with _repeat:
$ alert "Do you really want to delete all your files?"
####################################################
##  Do you really want to delete all your files?  ##
####################################################
The border character can be changed with a command-line argument:
$ alert "Danger, Will Robinson" $
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$  Danger, Will Robinson  $$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
Processing Character by Character
There are no direct parameter expansions to give either the first or last character of a string, but by using the wildcard (?), a string can be expanded to everything except its first or last character:
$ var=strip
$ allbutfirst=${var#?}
$ allbutlast=${var%?}
$ sa "$allbutfirst" "$allbutlast"
:trip:
:stri:
The values of allbutfirst and allbutlast can then be removed from the original variable to give the first or last character:
$ first=${var%"$allbutfirst"}
$ last=${var#"$allbutlast"}
$ sa "$first" "$last"
:s:
:p:
The first character of a string can also be obtained with printf:
printf -v first "%c" "$var"
To operate on each character of a string one at a time, use a while loop and a temporary variable that stores the value of var minus its first character. The temp variable is then used as the pattern in a ${var%PATTERN} expansion. Finally, $temp is assigned to var, and the loop continues until there are no characters left in var:
while [ -n "$var" ]
do
  temp=${var#?}        ## everything but the first character
  char=${var%"$temp"}  ## remove everything but the first character
  : do something with "$char"
  var=$temp            ## assign truncated value to var
done
Reversal
You can use the same method to reverse the order of characters in a string. Each letter is tacked on to the end of a new variable (Listing 7-3).
Listing 7-3. revstr, Reverse the Order of a String; Store Result in _REVSTR
_revstr() #@ USAGE: revstr STRING
{
  var=$1
  _REVSTR=
  while [ -n "$var" ]
  do
    temp=${var#?}
    _REVSTR=$temp${var%"$temp"}
    var=$temp
  done
}
Case Conversion
In the Bourne shell, case conversion was done with external commands such as tr, which translates characters in its first argument to the corresponding character in its second argument:
$ echo abcdefgh | tr ceh CEH # c => C, e => E, h => H
abCdEfgH
$ echo abcdefgh | tr ceh HEC # c => H, e => E, h => C
abHdEfgC
Ranges specified with a hyphen are expanded to include all intervening characters:
$ echo touchdown | tr 'a-z' 'A-Z'
TOUCHDOWN
In the POSIX shell, short strings can be converted efficiently using parameter expansion and a function containing a case statement as a lookup table. The function looks up the first character of its first argument and stores the uppercase equivalent in _UPR. If the first character is not a lowercase letter, it is unchanged (Listing 7-4).
Listing 7-4. to_upper, Convert First Character of $1 to Uppercase
to_upper()
    case $1 in
        a*) _UPR=A ;; b*) _UPR=B ;; c*) _UPR=C ;; d*) _UPR=D ;;
        e*) _UPR=E ;; f*) _UPR=F ;; g*) _UPR=G ;; h*) _UPR=H ;;
        i*) _UPR=I ;; j*) _UPR=J ;; k*) _UPR=K ;; l*) _UPR=L ;;
        m*) _UPR=M ;; n*) _UPR=N ;; o*) _UPR=O ;; p*) _UPR=P ;;
        q*) _UPR=Q ;; r*) _UPR=R ;; s*) _UPR=S ;; t*) _UPR=T ;;
        u*) _UPR=U ;; v*) _UPR=V ;; w*) _UPR=W ;; x*) _UPR=X ;;
        y*) _UPR=Y ;; z*) _UPR=Z ;;  *) _UPR=${1%${1#?}} ;;
    esac
To capitalize a word (that is, just the first letter), call to_upper with the word as an argument, and append the rest of the word to $_UPR:
$ word=function
$ to_upper "$word"
$ printf "%c%s\n" "$_UPR" "${word#?}"
Function
To convert the entire word to uppercase, you can use the upword function shown in Listing 7-5.
Listing 7-5. upword, Convert Word to Uppercase
_upword() #@ USAGE: upword STRING
{
  local word=$1
  while [ -n "$word" ] ## loop until nothing is left in $word
  do
    to_upper "$word"
    _UPWORD=$_UPWORD$_UPR
    word=${word#?} ## remove the first character from $word
  done
}

upword()
{
  _upword "$@"
  printf "%s\n" "$_UPWORD"
}
You can use the same technique to convert uppercase to lowercase; you can try to write the code for that as an exercise.
The basics of case conversion using the parameter expansions introduced in bash-4.x were covered in Chapter 5. Some uses for them are shown in the following sections.
Comparing Contents Without Regard to Case
When getting user input, a programmer often wants to accept it in either uppercase or lowercase or even a mixture of the two. When the input is a single letter, as in asking for Y or N, the code is simple. There is a choice of using the or symbol (|):
read ok
case $ok in
  y|Y) echo "Great!" ;;
  n|N) echo Good-bye
       exit 1
       ;;
  *) echo Invalid entry ;;
esac
or a bracketed character list:
read ok
case $ok in
  [yY]) echo "Great!" ;;
  [nN]) echo Good-bye
       exit 1
       ;;
  *) echo Invalid entry ;;
esac
When the input is longer, the first method requires all possible combinations to be listed, for example:
jan | jaN | jAn | jAN | Jan | JaN | JAn | JAN) echo "Great!" ;;
The second method works but is ugly and hard to read, and the longer the string is, the harder and uglier it gets:
read monthname
case $monthname in ## convert $monthname to number
  [Jj][Aa][Nn]*) month=1 ;;
  [Ff][Ee][Bb]*) month=2 ;;
  ## ...put the rest of the year here
  [Dd][Ee][Cc]*) month=12 ;;
  [1-9]|1[0-2]) month=$monthname ;; ## accept number if entered
  *) echo "Invalid month: $monthname" >&2 ;;
esac
A better solution is to convert the input to uppercase first and then compare it:
_upword "$monthname"
case $_UPWORD in ## convert $monthname to number
  JAN*) month=1 ;;
  FEB*) month=2 ;;
  ## ...put the rest of the year here
  DEC*) month=12 ;;
  [1-9]|1[0-2]) month=$monthname ;; ## accept number if entered
  *) echo "Invalid month: $monthname" >&2 ;;
esac
  Note  See Listing 7-11 at the end of this chapter for another method of converting a month name to a number.
In bash-4.x, you can replace the _upword function with case ${monthname^^} in, although I might keep it in a function to ease transition between versions of bash:
_upword()
{
  _UPWORD=${1^^}
}
Check for Valid Variable Name
You and I know what constitutes a valid variable name, but do your users? If you ask a user to enter a variable name, as you might in a script that creates other scripts, you should check that what is entered is a valid name. The function to do that is a simple check for violation of the rules: a name must contain only letters, numbers, and underscores and must begin with a letter or an underscore (Listing 7-6).
Listing 7-6. validname, Check $1 for a Valid Variable or Function Name
validname() #@ USAGE: validname varname
 case $1 in
   ## doesn't begin with a letter or an underscore, or
   ## contains something that is not a letter, a number, or an underscore
   [!a-zA-Z_]* | *[!a-zA-z0-9_]* ) return 1;;
 esac
The function is successful if the first argument is a valid variable name; otherwise, it fails.
$ for name in name1 2var first.name first_name last-name
> do
>   validname "$name" && echo " valid: $name" || echo "invalid: $name"
> done
  valid: name1
invalid: 2var
invalid: first.name
  valid: first_name
invalid: last-name
Insert One String into Another
To insert a string into another string, it is necessary to split the string into two parts – the part that will be to the left of the inserted string and the part to the right. Then the insertion string is sandwiched between them.
This function takes three arguments: the main string, the string to be inserted, and the position at which to insert it. If the position is omitted, it defaults to inserting after the first character. The work is done by the first function, which stores the result in _insert_string. This function can be called to save the cost of using command substitution. The insert_string function takes the same arguments, which it passes to _insert_string and then prints the result (Listing 7-7).
Listing 7-7. insert_string, Insert One String into Another at a Specified Location
_insert_string() #@ USAGE: _insert_string STRING INSERTION [POSITION]
{
  local insert_string_dflt=2                 ## default insert location
  local string=$1                            ## container string
  local i_string=$2                          ## string to be inserted
  local i_pos=${3:-${insert_string_dflt:-2}} ## insert location
  local left right                           ## before and after strings
  left=${string:0:$(( $i_pos - 1 ))}         ## string to left of insert
  right=${string:$(( $i_pos - 1 ))}          ## string to right of insert
  _insert_string=$left$i_string$right        ## build new string
}

insert_string()
{
  _insert_string "$@" && printf "%s\n" "$_insert_string"
}
Examples
$ insert_string poplar u 4
popular
$ insert_string show ad 3
shadow
$ insert_string tail ops  ## use default position
topsail
Overlay
To overlay a string on top of another string (replacing, overwriting), the technique is similar to inserting a string, the difference being that the right side of the string begins not immediately after the left side but at the length of the overlay further along (Listing 7-8).
Listing 7-8. overlay, Place One String Over the Top of Another
_overlay() #@ USAGE: _overlay STRING SUBSTRING START
{          #@ RESULT: in $_OVERLAY
  local string=$1
  local sub=$2
  local start=$3
  local left right
  left=${string:0:start-1}        ## See note below
  right=${string:start+${#sub}-1}
  _OVERLAY=$left$sub$right
}

overlay() #@ USAGE: overlay STRING SUBSTRING START
{
  _overlay "$@" && printf "%s\n" "$_OVERLAY"
}
  Note  The arithmetic within the substring expansion doesn’t need the full POSIX arithmetic syntax; bash will evaluate an expression if it finds one in the place of an integer.
Examples
$ {
> overlay pony b 1
> overlay pony u 2
> overlay pony s 3
> overlay pony d 4
> }
bony
puny
posy
pond
Trim Unwanted Characters
Variables often arrive with unwanted padding: usually spaces or leading zeroes. These can easily be removed with a loop and a case statement:
var="     John    "
while :   ## infinite loop
do
  case $var in
      ' '*) var=${var#?} ;; ## if $var begins with a space remove it
      *' ') var=${var%?} ;; ## if $var ends with a space remove it
      *) break ;; ## no more leading or trailing spaces, so exit the loop
  esac
done
A faster method finds the longest string that doesn’t begin or end with the character to be trimmed and then removes everything but that from the original string. This is similar to getting the first or last character from a string, where we used allbutfirst and allbutlast variables.
If the string is "   John   ", the longest string that ends in a character that is not to be trimmed is "   John". That is removed, and the spaces at the end are stored in rightspaces with this:
rightspaces=${var##*[! ]} ## remove everything up to the last non-space
Then you remove $rightspaces from $var:
var=${var%"$rightspaces"} ## $var now contains "     John"
Next, you find all the spaces on the left with this:
leftspaces=${var%%[! ]*} ## remove from the first non-space to the end
Remove $leftspaces from $var:
var=${var#"$leftspaces"} ## $var now contains "John"
This technique is refined a little for the trim function (Listing 7-9). Its first argument is the string to be trimmed. If there is a second argument, that is the character that will be trimmed from the string. If no character is supplied, it defaults to a space.
Listing 7-9. trim, Trim Unwanted Characters
_trim() #@ Trim spaces (or character in $2) from $1
{
  local trim_string
  _TRIM=$1
  trim_string=${_TRIM##*[!${2:- }]}
  _TRIM=${_TRIM%"$trim_string"}
  trim_string=${_TRIM%%[!${2:- }]*}
  _TRIM=${_TRIM#"$trim_string"}
}

trim() #@ Trim spaces (or character in $2) from $1 and print the result
{
  _trim "$@" && printf "%s\n" "$_TRIM"
}
Examples
$ trim "   S p a c e d  o u t   "
S p a c e d  o u t
$ trim "0002367.45000" 0
2367.45
Index
The index function converts a month name into its ordinal number; it returns the position of one string inside another (Listing 7-10). It uses parameter expansion to extract the string that precedes the substring. The index of the substring is one more than the length of the extracted string.
Listing 7-10. index, Return Position of One String Inside Another
_index() #@ Store position of $2 in $1 in $_INDEX
{
  local idx
  case $1 in
    "")  _INDEX=0; return 1 ;;
    *"$2"*) ## extract up to beginning of the matching portion
            idx=${1%%"$2"*}
            ## the starting position is one more than the length
           _INDEX=$(( ${#idx} + 1 )) ;;
    *) _INDEX=0; return 1 ;;
  esac
}

index()
{
  _index "$@"
  printf "%d\n" "$_INDEX"
}
Listing 7-11 shows the function to convert a month name to a number. It converts the first three letters of the month name to uppercase and finds its position in the months string. It divides that position by 4 and adds 1 to get the month number.
Listing 7-11. month2num, Convert a Month Name to Its Ordinal Number
_month2num()
{
  local months=JAN.FEB.MAR.APR.MAY.JUN.JUL.AUG.SEP.OCT.NOV.DEC
  _upword "${1:0:3}" ## take first three letters of $1 and convert to uppercase
  _index "$months" "$_UPWORD" || return 1
  _MONTH2NUM=$(( $_INDEX / 4 + 1 ))
}

month2num()
{
  _month2num "$@" &&
  printf "%s\n" "$_MONTH2NUM"
}
Summary
You learned the following commands and functions in this chapter.
Commands
   + tr: Translates characters
Functions
   + repeat: Repeats a string until it has length N
   + alert: Prints a warning message with a border and a beep
   + revstr: Reverses the order of a string; stores result in _REVSTR
   + to_upper: Converts the first character of $1 to uppercase
   + upword: Converts a word to uppercase
   + validname: Checks $1 for a valid variable or function name
   + insert_string: Inserts one string into another at a specified location
   + overlay: Places one string over the top of another
   + trim: Trims unwanted characters
   + index: Returns the position of one string inside another
   + month2num: Converts a month name to its ordinal number
Exercises
1.	What is wrong with this code (besides the inefficiency noted at the beginning of the chapter)?
if ! echo ${PATH} |grep -q /usr/games
  PATH=$PATH:/usr/games
fi
2.	Write a function called to_lower that does the opposite of the to_upper function in Listing 7-4.
3.	Write a function, palindrome, which checks whether its command-line argument is a palindrome (that is, a word or phrase that is spelled the same backward and forward). Note that spaces and punctuation are ignored in the test. Exit successfully if it is a palindrome. Include an option to print a message as well as set the return code.
4.	Write two functions, ltrim and rtrim, which trim characters in the same manner as trim but from only one side of the string, left and right, respectively.
