## CHAPTER 8

File Operations and Commands
Because the shell is an interpreted language, it is comparatively slow. Many operations on files are best done with external commands that implicitly loop over the lines of a file. At other times, the shell itself is more efficient. This chapter looks at how the shell works with files – both shell options that modify and extend file name expansion and shell options that read and modify the contents of files. Several external commands that work on files are explained, often accompanied by examples of when not to use them.
Some of the scripts in this chapter use an especially prepared file containing the King James version of the Bible. The file can be downloaded from http://cfaj.freeshell.org/kjv/kjv.txt. Download it to your home directory with wget:
wget http://cfaj.freeshell.org/kjv/kjv.txt
In this file, each verse of the Bible is on a single line preceded by the name of the book and the chapter and verse numbers, all delimited with colons:
Genesis:001:001:In the beginning God created the heaven and the earth.
Exodus:020:013:Thou shalt not kill.
Exodus:022:018:Thou shalt not suffer a witch to live.
John:011:035:Jesus wept.
The path to the file will be kept in the variable kjv, which will be used whenever the file is needed.
export kjv=$HOME/kjv.txt
Reading a File
The most basic method of reading the contents of a file is a while loop with its input redirected:
while read  ## no name supplied so the variable REPLY is used
do
  : do something with "$REPLY" here
done < "$kjv"
The file will be stored, one line at a time, in the variable REPLY. More commonly, one or more variable names will be supplied as arguments to read:
while read name phone
do
  printf "Name: %-10s\tPhone: %s\n" "$name" "$phone"
done < "$file"
The lines are split using the characters in IFS as word delimiters. If the file contained in $file contains these two lines:
John 555-1234
Jane 555-7531
the output of the previous snippet will be as follows:
Name: John      Phone: 555-1234
Name: Jane      Phone: 555-7531
By changing the value of IFS before the read command, other characters can be used for word splitting. The same script, using only a hyphen in IFS instead of the default space, tab, and newline, would produce this:
$ while IFS=- read name phone
> do
>  printf "Name: %-10s\tPhone: %s\n" "$name" "$phone"
> done < "$file"
Name: John 555  Phone: 1234
Name: Jane 555  Phone: 7531
Placing an assignment in front of a command causes it to be local to that command and does not change its value elsewhere in the script.
To read the King James version of the Bible (henceforth referred to as KJV), the field separator IFS should be set to a colon so that lines can be split into book, chapter, verse, and text, each being assigned to a separate variable (Listing 8-1).
Listing 8-1. kjvfirsts, Print Book, Chapter, Verse, and First Words from KJV
while IFS=: read book chapter verse text
do
  firstword=${text%% *}
  printf "%s %s:%s %s\n" "$book" "$chapter" "$verse" "$firstword"
done < "$kjv"
The output (with more than 31,000 lines replaced by a single ellipsis) looks like this:
Genesis 001:001 In
Genesis 001:002 And
Genesis 001:003 And
...
Revelation 022:019 And
Revelation 022:020 He
Revelation 022:021 The
The awk programming language is often used in shell scripts when the shell itself is too slow (as in this case) or when features not present in the shell are required (for example, arithmetic using decimal fractions). The language is explained in somewhat more detail in the following section.
External Commands
You can accomplish many tasks using the shell without calling any external commands. Some use one or more commands to provide data for a script to process. Other scripts are best written with nothing but external commands.
Often, the functionality of an external command can be duplicated within the shell, and sometimes it cannot. Sometimes using the shell is the most efficient method; sometimes it is the slowest. Here I’ll cover a number of external commands that process files and show how they are used (and often misused). These are not detailed explanations of the commands; usually they are an overview with, in most cases, a look at how they are used – or misused – in shell scripts.
cat
One of the most misused commands, cat reads all the files on its command line and prints their contents to the standard output. If no file names are supplied, cat reads the standard input. It is an appropriate command when more than one file needs to be read or when a file needs to be included with the output of other commands:
cat *.txt | tr aeiou AEIOU > upvowel.txt

{
  date                ## Print the date and time
  cat report.txt      ## Print the contents of the file
  printf "Signed: "   ## Print "Signed: " without a newline
  whoami              ## Print the user's login name
} | mail -s "Here is the report" paradigm@example.com
It is not necessary when the file or files could have been placed on the command line:
cat thisfile.txt | head -n 25 > thatfile.txt  ## WRONG
head -n 25 thisfile.txt > thatfile.txt        ## CORRECT
It is useful when more than one file (or none) needs to be supplied to a command that cannot take a file name as an argument or can take only a single file, as in redirection. It is useful when one or more file names may or may not be on the command line. If no files are given, the standard input is used:
cat "$@" | while read x; do whatever; done
The same thing can be done using process substitution, the advantage being that variables modified within the while loop will be visible to the rest of the script. The disadvantage is that it makes the script less portable.
while read x; do : whatever; done < <( cat "$@" )
Another frequent misuse of cat is to use the output as a list with for:
for line in $( cat "$kjv" ); do n=$(( ${n:-0} + 1 )); done
That script does not put lines into the line variable; it reads each word into it. The value of n will be 795989, which is the number of words in the file. There are 31,102 lines in the file. (And if you really wanted that information, you would use the wc command.)
head
By default, head prints the first ten lines of each file on the command line, or from the standard input if no file name is given. The -n option changes that default:
$ head -n 1 "$kjv"
Genesis:001:001:In the beginning God created the heaven and the earth.
The output of head, like that of any command, can be stored in a variable:
filetop=$( head -n 1 "$kjv")
In that instance, head is unnecessary; this shell one liner does the same thing without any external command:
read filetop < "$kjv"
Using head to read one line is especially inefficient when the variable then has to be split into its constituent parts:
book=${filetop%%:*}
text=${filetop##*:}
That can be accomplished much more rapidly with read:
$ IFS=: read book chapter verse text < "$kjv"
$ sa "$book" "$chapter" "$verse" "${text%% *}"
:Genesis:
:001:
:001:
:In:
Even reading multiple lines into variables can be faster using the shell instead of head:
{
  read line1
  read line2
  read line3
  read line4
} < "$kjv"
or, you can put the lines into an array:
for n in {1..4}
do
  read lines[${#lines[@]}]
done < "$kjv"
In bash-4.x, the new builtin command mapfile can also be used to populate an array:
mapfile -tn 4 lines < "$kjv"
The mapfile command is explained in more detail in Chapter 13.
touch
The default action of touch is to update the timestamp of a file to the current time, creating an empty file if it doesn’t exist. An argument to the -d option changes the timestamp to that time rather than the present. It is not necessary to use touch to create a file. The shell can do it with redirection:
> filename
Even to create multiple files, the shell is faster:
for file in {a..z}$RANDOM
do
  > "$file"
done
ls
Unless used with one or more options, the ls command offers little functional advantage over shell file name expansion. Both list files in alphabetical order. If you want the files displayed in neat columns across the screen, ls is useful. If you want to do anything with those file names, it can be done better, and often more safely, in the shell.
With options, however, it’s a different matter. The -l option prints more information about the file, including its permissions, owner, size, and date of modification. The -t option sorts the files by last modification time, most recent first. The order (whether by name or by time) is reversed with the -r option.
ls is many times misused in a manner that can break a script. File names containing spaces are an abomination, but they are so common nowadays that scripts must take their possibility (or would it be, say, inevitability?) into account. In the following construction (that is seen all too often), not only is ls unnecessary, but its use will break the script if any file names contain spaces:
for file in $(ls); do
The result of command substitution is subject to word splitting, so file will be assigned to each word in a file name if it contains spaces:
$ touch {zzz,xxx,yyy}\ a  ## create 3 files with a space in their names
$ for file in $(ls *\ *); do echo "$file"; done
xxx
a
yyy
a
zzz
a
On the other hand, using file name expansion gives the desired (that is, correct) results:
$ for file in *\ *; do echo "$file"; done
xxx a
yyy a
zzz a
cut
The cut command extracts portions of a line, specified either by character or by field. Cut reads from files listed on the command line or from the standard input if no files are specified. The selection to be printed is done by using one of three options, -b, -c, and -f, which stand for bytes, characters, and fields. Bytes and characters differ only when used in locales with multibyte characters. Fields are delimited by a single tab (consecutive tabs delimit empty fields), but that can be changed with the -d option.
The -c option is followed by one or more character positions. Multiple columns (or fields when the -f option is used) can be expressed by a comma-separated list or by a range:
$ cut -c 22 "$kjv" | head -n3
e
h
o
$ cut -c 22,24,26 "$kjv" | head -n3
ebg
h a
o a
$ cut -c 22-26 "$kjv" | head -n3
e beg
he ea
od sa
A frequent misuse of cut is to extract a portion of a string. Such manipulations can be done with shell parameter expansion. Even if it takes two or three steps, it will be much faster than calling an external command.
$ boys="Brian,Carl,Dennis,Mike,Al"
$ printf "%s\n" "$boys" | cut -d, -f3  ## WRONG
Dennis
$ IFS=,          ## Better, no external command used
$ boyarray=( $boys )
$ printf "%s\n" "${boyarray[2]}"
Dennis
$ temp=${boys#*,*,} ## Better still, and more portable
$ printf "%s\n" "${temp%%,*}"
Dennis
wc
To count the number of lines, words, or bytes in a file, use wc. By default, it prints all three pieces of information in that order followed by the name of the file. If multiple file names are given on the command line, it prints a line of information for each one and then the total:
$ wc "$kjv" /etc/passwd
  31102  795989 4639798 /home/chris/kjv.txt
     50     124    2409 /etc/passwd
  31152  796113 4642207 total
If there are no files on the command line, cut reads from the standard input:
$ wc < "$kjv"
  31102  795989 4639798
The output can be limited to one or two pieces of information by using the -c, -w, or -l option. If any options are used, wc prints only the information requested:
$ wc -l "$kjv"
31102 /home/chris/kjv.txt
Newer versions of wc have another option, -m, which prints the number of characters, which will be less than the number of bytes if the file contains multibyte characters. The default output remains the same, however.
As with so many commands, wc is often misused to get information about a string rather than a file. To get the length of a string held in a variable, use parameter expansion: ${#var}. To get the number of words, use set and the special parameter $#:
set -f
set -- $var
echo $#
To get the number of lines, use this:
IFS=$'\n'
set -f
set -- $var
echo $#
Regular Expressions
Regular expressions (often called regexes or regexps) are a more powerful form of pattern matching than file name globbing and can express a much wider range of patterns more precisely. They range from very simple (a letter or number is a regex that matches itself) to the mind-bogglingly complex. Long expressions are built with a concatenation of shorter expressions and, when broken down, are not hard to understand.
There are similarities between regexes and file-globbing patterns: a list of characters within square brackets matches any of the characters in the list. An asterisk matches zero or more – not any character as in file expansion – of the preceding character. A dot matches any character, so .* matches any string of any length, much as an asterisk does in a globbing pattern.
Three important commands use regular expressions: grep, sed, and awk. The first is used for searching files, the second for editing files, and the third for almost anything because it is a complete programming language in its own right.
grep
grep searches files on the command line, or the standard input if no files are given, and prints lines matching a string or regular expression.
$ grep ':0[57]0:001:' "$kjv" | cut -c -78
Genesis:050:001:And Joseph fell upon his father's face, and wept upon him, and
Psalms:050:001:The mighty God, even the LORD, hath spoken, and called the eart
Psalms:070:001:MAKE HASTE, O GOD, TO DELIVER ME; MAKE HASTE TO HELP ME, O LORD
Isaiah:050:001:Thus saith the LORD, Where is the bill of your mother's divorce
Jeremiah:050:001:The word that the LORD spake against Babylon and against the
The shell itself could have done the job:
while read line
do
  case $line in
    *0[57]0:001:*) printf "%s\n" "${line:0:78}" ;;
  esac
done < "$kjv"
but it takes many times longer.
Often grep and other external commands are used to select a small number of lines from a file and pipe the results to a shell script for further processing:
$ grep 'Psalms:023' "$kjv" |
> {
> total=0
> while IFS=: read book chapter verse text
> do
>   set -- $text  ## put the verse into the positional parameters
>   total=$(( $total + $# )) ## add the number of parameters
> done
> echo $total
}
118
grep should not be used to check whether one string is contained in another. For that, there is case or bash’s expression evaluator, [[ ... ]].
sed
For replacing a string or pattern with another string, nothing beats the stream editor sed. It is also good for pulling a particular line or range of lines from a file. To get the first three lines of the book of Leviticus and convert the name of the book to uppercase, you’d use this:
$ sed -n '/Lev.*:001:001/,/Lev.*:001:003/ s/Leviticus/LEVITICUS/p' "$kjv" |
> cut -c -78
LEVITICUS:001:001:And the LORD called unto Moses, and spake unto him out of th
LEVITICUS:001:002:Speak unto the children of Israel, and say unto them, If any
LEVITICUS:001:003:If his offering be a burnt sacrifice of the herd, let him of
The -n option tells sed not to print anything unless specifically told to do so; the default is to print all lines whether modified or not. The two regexes, enclosed in slashes and separated by a comma, define a range from the line that matches the first one to the line that matches the second; s is a command to search and replace and is probably the one most often used.
When modifying a file, the standard Unix practice is to save the output to a new file and then move it to the place of the old one if the command is successful:
sed 's/this/that/g' "$file" > tempfile && mv tempfile "$file"
Some recent versions of sed have an -i option that will change the file in situ. If used, the option should be given a suffix to make a backup copy in case the script mangles the original irretrievably:
sed -i.bak 's/this/that/g' "$file"
More complicated scripts are possible with sed, but they quickly become very hard to read. This example is far from the worst I’ve seen, but it takes much more than a glance to figure out what it is doing. (It searches for Jesus wept and prints lines containing it along with the lines before and after; you can find a commented version at http://www.grymoire.com/Unix/Sed.html.)
sed -n '
/Jesus wept/ !{
    h
}
/Jesus wept/ {
    N
    x
    G
    p
    a\
---
    s/.*\n.*\n\(.*\)$/\1/
    h
}' "$kjv"
As you’ll see shortly, the same program in awk is comparatively easy to understand.
There will be more examples of sed in later chapters, so we’ll move on with the usual admonishment that external commands should be used on files, not strings. ‘Nuff sed!
awk
awk is a pattern scanning and processing language. An awk script is composed of one or more condition-action pairs. The condition is applied to each line in the file or files passed on the command line or to the standard input if no files are given. When the condition resolves successfully, the corresponding action is performed.
The condition may be a regular expression, a test of a variable, an arithmetic expression, or anything that produces a non-zero or nonempty result. It may represent a range by giving two condition separated by a comma; once a line matches the first condition, the action is performed until a line matches the second condition. For example, this condition matches input lines 10 to 20 inclusive (NR is a variable that contains the current line number):
NR == 10, NR == 20
There are two special conditions, BEGIN and END. The action associated with BEGIN is performed before any lines are read. The END action is performed after all the lines have been read or another action executes an exit statement.
The action can be any computation task. It can modify the input line, it can save it in a variable, it can perform a calculation on it, it can print some or all of the line, and it can do anything else you can think of.
Either the condition or the action may be missing. If there is no condition, the action is applied to all lines. If there is no action, matching lines are printed.
Each line is split into fields based on the contents of the variable FS. By default, it is any whitespace. The fields are numbered: $1, $2, and so on. $0 contains the entire line. The variable NF contains the number of fields in the line.
In the awk version of the kjvfirsts script, the field separator is changed to a colon using the -F command-line option (Listing 8-2). There is no condition, so the action is performed for every line. It splits the fourth field, the verse itself, into words, and then it prints the first three fields and the first word of the verse.
Listing 8-2. kjvfirsts-awk, Print Book, Chapter, Verse, and First Words from the KJV
awk -F: '  ## -F: sets the field delimiter to a colon
{
 ## split the fourth field into an array of words
 split($4,words," ")
 ## printf the first three fields and the first word of the fourth
 printf "%s %s:%s %s\n", $1, $2, $3, words[1]
}' "$kjv"
To find the shortest verse in the KJV, the next script checks the length of the fourth field. If it is less than the value of the shortest field seen so far, its length (minus the length of the name of the book), measured with the length() function, is stored in min, and the line is stored in verse. At the end, the line stored in verse is printed.
$ awk -F: 'BEGIN { min = 999 } ## set min larger than any verse length
length($0) - length($1) < min {
   min = length($0) – length($1)
   verse = $0
 }
END { print verse }' "$kjv"
John:011:035:Jesus wept.
As promised, here is an awk script that searches for a string (in this case, Jesus wept) and prints it along with the previous and next lines:
awk '/Jesus wept/ {
   print previousline
   print $0
   n = 1
   next
  }
n == 1 {
   print $0
   print "---"
   n = 2
  }
  {
   previousline = $0
  }' "$kjv"
To total a column of numbers:
$ printf "%s\n" {12..34} | awk '{ total += $1 }
> END { print total }'
529
This has been a very rudimentary look at awk. There will be a few more awk scripts later in the book, but for a full understanding, there are various books on awk:
   + The AWK Programming Language by the language’s inventors (Alfred V. Aho, Peter J. Weinberger, and Brian W. Kernighan)
   + sed & awk by Dale Dougherty and Arnold Robbins
   + Effective awk Programming by Arnold Robbins
Or start with the main page.
File Name Expansion Options
To show you the effects of the various file name expansion options, the sa command defined in Chapter 4 as well as pr4, a function that prints its arguments in four columns across the screen will be used. The script sa is implemented as a function, along with pr4 and have been added to the .bashrc file:
sa()
{
    pre=: post=:
    printf "$pre%s$post\n" "$@"
}
The pr4 function prints its argument in four equal columns, truncating any string that is too long for its allotted space:
pr4()
{
    ## calculate column width
    local width=$(( (${COLUMNS:-80} - 2) / 4 ))

    ## Note that braces are necessary on the second $width to separate it from 's'
    local s=%-$width.${width}s
    printf "$s $s $s $s\n" "$@"
}
There are six shell options that affect the way in which file names are expanded. They are enabled and disabled with the shopt command using options -s and -u, respectively:
shopt -s extglob      ## enable the extglob option
shopt -u nocaseglob   ## disable the nocaseglob option
To demonstrate the various globbing options, we’ll create a directory, cd to it, and put some empty files in it:
$ mkdir "$HOME/globfest" && cd "$HOME/globfest" || echo Failed >&2
$ touch {a..f}{0..9}{t..z}$RANDOM .{a..f}{0..9}$RANDOM
This has created 420 files beginning with a letter and 60 beginning with a dot. There are, for example, 7 files beginning with a1:
$ sa a1*
:a1t18345:
:a1u18557:
:a1v12490:
:a1w22008:
:a1x6088:
:a1y28651:
:a1z18318:
nullglob
Normally, when a wildcard pattern doesn’t match any files, the pattern remains the same:
$ sa *xy
:*xy:
If the nullglob option is set and there is no match, an empty string is returned:
$ shopt -s nullglob
$ sa *xy
::
$ shopt -u nullglob   ## restore the default behavior
failglob
If the failglob option is set and no files match a wildcard pattern, an error message is printed:
$ shopt -s failglob
$ sa *xy
bash: no match: *xy
$ shopt -u failglob   ## restore the default behavior
dotglob
A wildcard at the beginning of a file name expansion pattern does not match file names that begin with a dot. These are intended to be “hidden” files and are not matched by standard file name expansion:
$ sa * | wc -l  ## not dot files
420
To match “dot” files, the leading dot must be given explicitly:
$ sa .* | wc -l ## dot files; includes . and ..
62
The touch command at the beginning of this section created 60 dot files. The .* expansion shows 62 because it includes the hard-linked entries . and .. that are created in all subdirectories.
The dotglob option causes dot files to be matched just like any other files:
$ shopt -s dotglob
$ printf "%s\n" * | wc -l
480
Expansions of *, with dotglob enabled, do not include the hard links . and ...
extglob
When extended globbing is turned on with shopt -s extglob, five new file name expansion operators are added. In each case, the pattern-list is a list of pipe-separated globbing patterns. It is enclosed in parentheses, which are preceded by ?, *, +, @, or !, for example, +(a[0-2]|34|2u), ?(john|paul|george|ringo).
To demonstrate extended globbing, remove the existing files in $HOME/globfest, and create a new set:
$ cd $HOME/globfest
$ rm *
$ touch {john,paul,george,ringo}{john,paul,george,ringo}{1,2}$RANDOM\
> {john,paul,george,ringo}{1,2}$RANDOM{,,} {1,2}$RANDOM{,,,}
?(pattern-list)
This pattern-list matches zero or one occurrence of the given patterns. For example, the pattern ?(john|paul)2 matches john2, paul2, and 2:
$ pr4 ?(john|paul)2*
222844              228151              231909              232112
john214726          john216085          john26              paul218047
paul220720          paul231051
*(pattern-list)
This is like the previous form, but it matches zero or more occurrences of the given patterns; *(john|paul)2 will match all files matched in the previous example, as well as those that have either pattern more than once in succession:
pr4 *(john|paul)2*
222844              228151              231909              232112
john214726          john216085          john26              johnjohn23185
johnpaul25000       paul218047          paul220720          paul231051
pauljohn221365      paulpaul220101
@(pattern-list)
The pattern @(john|paul)2 matches files that have a single instance of either pattern followed by a 2:
$ pr4 @(john|paul)2*
john214726          john216085          john26              paul218047
paul220720          paul231051
+(pattern-list)
The pattern +(john|paul)2 matches files that begin with one or more instances of a pattern in the list followed by a 2:
$ pr4 +(john|paul)2*
john214726          john216085          john26              johnjohn23185
johnpaul25000       paul218047          paul220720          paul231051
pauljohn221365      paulpaul220101
!(pattern-list)
The last extended globbing pattern matches anything except one of the given patterns. It differs from the rest in that each pattern must match the entire file name. The pattern !(r|p|j)* will not exclude files beginning with r, p, or j (or any others), but the following pattern will (and will also exclude files beginning with a number):
$ pr4 !([jpr0-9]*)
george115425        george132443        george1706          george212389
george223300        george27803         georgegeorge16122   georgegeorge28573
georgejohn118699    georgejohn29502     georgepaul12721     georgepaul222618
georgeringo115095   georgeringo227768
  Note  The explanation given here for the last of these patterns is simplified but should be enough to cover its use in the vast majority of cases. For a more complete explanation, see Chapter 9 in From Bash to Z Shell (Apress, 2005).
nocaseglob
When the nocaseglob option is set, lowercase letters match uppercase letters, and vice versa:
$ cd $HOME/globfest
$ rm -rf *
$ touch {{a..d},{A..D}}$RANDOM
$ pr4 *
A31783              B31846              C17836              D14046
a31882              b31603              c29437              d26729
The default behavior is for a letter to match only those of the same case:
$ pr4 [ab]*
a31882              b31603
The nocaseglob option causes a letter to match both cases:
$ shopt -s nocaseglob
$ pr4 [ab]*
A31783              B31846              a31882              b31603
globstar
Introduced in bash-4.0, the globstar option allows the use of ** to descend recursively into directories and subdirectories looking for matching files. As an example, create a hierarchy of directories:
$ cd $HOME/globfest
$ rm -rf *
$ mkdir -p {ab,ac}$RANDOM/${RANDOM}{q1,q2}/{z,x}$(( $RANDOM % 10 ))
The double asterisk wildcard expands to all the directories:
$ shopt -s globstar
$ pr4 **
ab11278             ab11278/22190q1     ab11278/22190q1/z7  ab1394
ab1394/10985q2      ab1394/10985q2/x5   ab4351              ab4351/23041q1
ab4351/23041q1/x1   ab4424              ab4424/8752q2       ab4424/8752q2/z9
ac11393             ac11393/20940q1     ac11393/20940q1/z4  ac17926
ac17926/19435q2     ac17926/19435q2/x0  ac23443             ac23443/5703q2
ac23443/5703q2/z4   ac5662              ac5662/17958q1      ac5662/17958q1/x4
Summary
Many external commands deal with files. In this chapter, the most important ones and those that are most often misused have been covered. They have not been covered in detail, and some emphasis has been placed on how to avoid calling them when the shell can do the same job more efficiently. Basically, it boils down to this: use external commands to process files, not strings.
Shell Options
   + nullglob: Returns null string if no files match pattern
   + failglob: Prints error message if no files match
   + dotglob: Includes dot files in pattern matching
   + extglob: Enables extended file name expansion patterns
   + nocaseglob: Matches files ignoring case differences
   + globstar: Searches file hierarchy for matching files
External Commands
   + awk: Is a pattern scanning and processing language
   + cat: Concatenates files and print on the standard output
   + cut: Removes sections from each line of one or more files
   + grep: Prints lines matching a pattern
   + head: Outputs the first part of one or more files
   + ls: Lists directory contents
   + sed: Is a stream editor for filtering and transforming text
   + touch: Changes file timestamps
   + wc: Counts lines, words, and characters in one or more files
Exercises
1.	Modify the kjvfirsts script: accept a command-line argument that specifies how many chapters are to be printed.
2.	Why are the chapter and verse numbers in kjvfirsts formatted with %s instead of %d?
3.	Write an awk script to find the longest verse in KJV.
