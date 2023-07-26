# CHAPTER 3

## Looping and Branching

At the heart of any programming language are iteration and conditional execution. Iteration is the repetition of a section of code until a condition changes. Conditional execution is making a choice between two or more actions (one of which may be to do nothing) based on a condition.
In the shell, there are three types of loop (while, until, and for) and three types of conditional execution (if, case, and the conditional operators && and ||, which mean AND and OR, respectively). With the exception of for and case, the exit status of a command controls the behavior.
Exit Status
You can test the success of a command directly using the shell keywords while, until, and if or with the control operators && and ||. The exit code is stored in the special parameter $?.
If the command executed successfully (or true), the value of $? is zero. If the command failed for some reason, $? will contain a positive integer between 1 and 255, inclusive. A failed command usually returns 1. Zero and non-zero exit codes are also known as true and false, respectively.
A command may fail because of a syntax error:
$ printf "%v\n"
bash: printf: `v': invalid format character
$ echo $?
1
Alternatively, failure may be the result of the command not being able to accomplish its task:
$ mkdir /qwerty
bash: mkdir: cannot create directory `/qwerty': Permission denied
$ echo $?
1
Testing an Expression
Expressions are deemed to be true or false by the test command or one of two nonstandard shell-reserved words, [[ and ((. The test command compares strings, integers, and various file attributes; (( tests arithmetic expressions, and [[ ... ]] does the same as test with the additional feature of comparing regular expressions.
test, a.k.a. [ … ]
The test command evaluates many kinds of expressions, from file properties to integers to strings. It is a builtin command, and therefore its arguments are expanded just as for any other command. (See Chapter 5 for more information.) The alternative version ([) requires a closing bracket at the end.
  Note  As noted earlier in Chapter 2, bash is particular about the spacing, and requires spaces around the brackets. It also is important because the command [ test and [test without the space are different from what is intended.
File Tests
Several operators test the state of a file. A file’s existence can be tested with -e (or the nonstandard -a). The type of file can be checked with -f for a regular file, -d for a directory, and -h or -L for a symbolic link. Other operators test for special types of files and for which permission bits are set.
Here are some examples:
test -f /etc/fstab    ## true if a regular file
test -h /etc/rc.local ## true if a symbolic link
[ -x "$HOME/bin/hw" ]   ## true if you can execute the file
[[ -s $HOME/bin/hw ]]  ## true if the file exists and is not empty
Integer Tests
Comparisons between integers use the -eq, -ne, -gt, -lt, -ge, and -le operators.
The equality of integers is tested with -eq:
$ test 1 -eq 1
$ echo $?
0
$ [ 2 -eq 1 ]
$ echo $?
1
Inequality is tested with -ne:
$ [ 2 -ne 1 ]
$ echo $?
0
The remaining operators test greater than, less than, greater than or equal to, and less than or equal to.
String Tests
Strings are concatenations of zero or more characters and can include any character except NUL (ASCII 0). They can be tested for equality or inequality, for nonempty string or null string, , and in bash for alphabetical ordering. The = operator tests for equality, in other words, whether they are identical; != tests for inequality. bash also accepts == for equality, but there is no reason to use this nonstandard operator.
Here are some examples:
test "$a" = "$b"
[ "$q" != "$b" ]
The -z and -n operators return successfully if their arguments are empty or nonempty:
$ [ -z "" ]
$ echo $?
0
$ test -n ""
$ echo $?
1
The greater-than and less-than symbols are used in bash to compare the lexical positions of strings and must be escaped to prevent them from being interpreted as redirection operators:
$ str1=abc
$ str2=def
$ test "$str1" \< "$str2"
$ echo $?
0
$ test "$str1" \> "$str2"
$ echo $?
1
The previous tests can be combined in a single call to test with the -a (logical AND) and -o (logical OR) operators:
test -f /path/to/file -a $test -eq 1
test -x bin/file -o $test -gt 1
test is usually used in combination with if or the conditional operators && and ||.
[[ … ]]: Evaluate an Expression
Like test, [[ ... ]] evaluates an expression. Unlike test, it is not a builtin command. It is part of the shell grammar and not subject to the same parsing as a builtin command. Parameters are expanded, but word splitting and file name expansion are not performed on words between [[ and ]].
It supports all the same operators as test, with some enhancements and additions. It is, however, nonstandard, so it is better not to use it when test could perform the same function.
Enhancements over Test
When the argument to the right of = or != is unquoted, it is treated as a pattern and duplicates the functionality of the case command.
The feature of [[ ... ]] that is not duplicated elsewhere in the shell is the ability to match an extended regular expression using the =~ operator:
$ string=whatever
$ [[ $string =~ h[aeiou] ]]
$ echo $?
0
$ [[ $string =~ h[sdfghjkl] ]]
$ echo $?
1
Regular expressions are explained in Chapter 8.
(( … )): Evaluate an Arithmetic Expression
A nonstandard feature, (( arithmetic expression )) returns false if the arithmetic expression evaluates to zero and returns true otherwise. The portable equivalent uses test and the POSIX syntax for shell arithmetic:
test $(( a - 2 )) -ne 0
[ $a != 0 ]
But because (( expression )) is shell syntax and not a builtin command, expression is not parsed in the same way as arguments to a command. This means, for example, that a greater than sign (>) or less than sign (<) is not interpreted as a redirection operator:
if (( total > max )); then : ...; fi
A bare variable is tested for zero or non-zero, exiting successfully if the variable is non-zero:
((verbose)) && command ## execute command if verbose != 0
Non-numeric values are equivalent to 0:
$ y=yes
$ ((y)) && echo $y || echo n
$ nLists
A list is a sequence of one or more commands separated by semicolons, ampersands, control operators, or newlines. A list may be used as the condition in a while or until loop, an if statement, or as the body of any loop. The exit code of a list is the exit code of the last command in the list.
Conditional Execution
Conditional constructs enable a script to decide whether to execute a block of code or to select which of two or more blocks to execute.
if
The basic if command evaluates a list of one or more commands and executes a list if the execution of <condition list> is successful:
if <condition list>
then
   <list>
fi
Usually, the <condition list> is a single command, very often test or its synonym, [, or, in bash, [[. In Listing 3-1, the -z operand to test checks whether a name was entered.
Listing 3-1. Read and Check Input
read name
if [[ -z $name ]]
then
   echo "No name entered" >&2
   exit 1  ## Set a failed return code
fi

Using the else keyword, a different set of commands can be executed if the <condition list> fails, as shown in Listing 3-2. Note that in numeric expressions variables do not require a leading $.
Listing 3-2. Prompt for a Number and Check That It Is Not Greater Than Ten
printf "Enter a number not greater than 10: "
read number
if (( number > 10 ))
then
    printf "%d is too big\n" "$number" >&2
    exit 1
else
    printf "You entered %d\n" "$number"
fi
More than one condition can be given, using the elif keyword, so that if the first test fails, the second is tried, as shown in Listing 3-3.
Listing 3-3. Prompt for a Number and Check That It Is Within a Given Range
printf "Enter a number between 10 and 20 inclusive: "
read number
if (( number < 10 ))
then
    printf "%d is too low\n" "$number" >&2
    exit 1
elif (( number > 20 ))
then
    printf "%d is too high\n" "$number" >&2
    exit 1
else
    printf "You entered %d\n" "$number"
fi
  Note  In real use, a number entered in the previous examples would be checked for invalid characters before its value is compared. Code to do that is given in the “case” section.
Often more than one test is given in the <condition list> using && and ||.
Conditional Operators, && and ||
Lists containing the AND and OR conditional operators are evaluated from left to right. A command following the AND operator (&&) is executed if the previous command is successful. The part following the OR operator (||) is executed if the previous command fails.
For example, to check for a directory and cd into it if it exists, use this:
test -d "$directory" && cd "$directory"
To change directory and exit with an error if cd fails, use this:
cd "$HOME/bin" || exit 1
The next command tries to create a directory and cd to it. If either mkdir or cd fails, it exits with an error:
mkdir "$HOME/bin" && cd "$HOME/bin" || exit 1
Conditional operators are often used with if. In this example, the echo command is executed if both tests are successful:

```sh
if [ -d "$dir" ] && cd "$dir"
then
    echo "$PWD"
fi
case
A case statement compares a word (usually a variable) against one or more patterns and executes the commands associated with that pattern. The patterns are pathname expansion patterns using wildcards (* and ?) and character lists and ranges ([...]). The syntax is as follows:
case WORD in
  PATTERN) COMMANDS ;;
  PATTERN) COMMANDS ;; ## optional
esac
```

A common use of case is to determine whether one string is contained in another. It is much faster than using grep, which creates a new process. This short script would normally be implemented as a shell function (see Chapter 6) so that it will be executed without creating a new process, as shown in Listing 3-4.

Listing 3-4. Does One String Contain Another?

```sh
case $1 in
    *"$2"*) true ;;
    *) false ;;
esac
The commands, true and false, do nothing but succeed or fail, respectively.
Another common task is to check whether a string is a valid number. Again, Listing 3-5 would usually be implemented as a function.
Listing 3-5. Is This a Valid Positive Integer?
case $1 in
    *[!0-9]*) false;;
    *) true ;;
esac
Many scripts require one or more arguments on the command line. To check whether there are the correct number, case is often used:
case $# in
    3) ;; ## We need 3 args, so do nothing
    *) printf "%s\n" "Please provide three names" >&2
       exit 1
       ;;
esac
Looping
When a command or series of commands needs to be repeated, it is put inside a loop. The shell provides three types of loop: while, until, and for. The first two execute until a condition is either true or false; the third loops through a list of values.
while
The condition for a while loop is a list of one or more commands, and the commands to be executed while the condition remains true are placed between the keywords do and done:
while <list>
do
  <list>
done
By incrementing a variable each time the loop is executed, the commands can be run a specific number of times:
n=1
while [ $n -le 10 ]
do
  echo "$n"
  n=$(( $n + 1 ))
done
The true command can be used to create an infinite loop:
while true ## ':' can be used in place of true
do
  read x
done
A while loop can be used to read line by line from a file:
while IFS= read -r line
do
  : do something with "$line"
done < FILENAME?
until
Rarely used, until loops as long as the condition fails. It is the opposite of while:
n=1
until [ $n -gt 10 ]
do
  echo "$n"
  n=$(( $n + 1 ))
done
for
At the top of a for loop, a variable is given a value from a list of words. On each iteration, the next word in the list is assigned:
for var in Canada USA Mexico
do
  printf "%s\n" "$var"
done
bash also has a nonstandard form similar to that found in the C programming language. The first expression is evaluated when the for loop starts, the second is a test condition, and the third is evaluated at the end of each iteration:
for (( n=1; n<=10; ++n ))
do
  echo "$n"
done
break
A loop can be exited at any point with the break command:
while :
do
  read x
  [ -z "$x" ] && break
done
With a numeric argument, break can exit multiple nested loops:
for n in a b c d e
do
  while true
  do
    if [ $RANDOM -gt 20000 ]
    then
      printf .
      break 2 ## break out of both while and for loops
    elif [ $RANDOM -lt 10000 ]
    then
      printf '"'
      break ## break out of the while loop
    fi
  done
done
echo
continue
Inside a loop, the continue command immediately starts a new iteration of the loop, by passing any remaining commands:
for n in {1..9} ## See Brace expansion in Chapter 4
do
  x=$RANDOM
  [ $x -le 20000 ] && continue
  echo "n=$n x=$x"
done
Summary
Looping and branching are major building blocks of a computer program. In this chapter, you learned the commands and operators used for these tasks.
Commands
   + test: Evaluates an expression and returns success or failure
   + if: Executes a set of command if a list of commands is successful and optionally executes a different set if it is not
   + case: Matches a word with one or more patterns and executes the commands associated with the first matching pattern
   + while: Repeatedly executes a set of commands while a list of commands executes successfully
   + until: Repeatedly executes a set of commands until a list of commands executes successfully
   + for: Repeatedly executes a set of commands for each word in a list
   + break: Exits from a loop
   + continue: Starts the next iteration of a loop immediately
Concepts
   + Exit status: The success or failure of a command, stored as 0 or a positive integer in the special parameter $?
   + List: A sequence of one or more commands separated by ;, &, &&, ||, or a newline
Exercises
1.	Write a script that asks the user to enter a number between 20 and 30. If the user enters an invalid number or a non-number, ask again. Repeat until a satisfactory number is entered.
2.	Write a script that prompts the user to enter the name of a file. Repeat until the user enters a file that exists.
