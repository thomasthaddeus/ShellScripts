# APPENDIX A

## Shell Variables

> This list is excerpted from the bash man page and edited to make a stand-alone document. The following variables are set by bash.

---

1. `BASH`
   - Expands to the full file name used to invoke this instance of bash.

2. `BASHPID`
   - Expands to the process ID of the current bash process. This differs from `$$` under certain circumstances, such as subshells that do not require bash to be reinitialized.

3. `BASH_ALIASES`
   - An associative array variable whose members correspond to the internal list of aliases as maintained by the alias builtin. Elements added to this array appear in the alias list; unsetting array elements causes aliases to be removed from the alias list.

4. `BASH_ARGC`
   - An array variable whose values are the number of parameters in each frame of the current bash execution call stack. The number of parameters to the current subroutine (shell function or script executed with . or source) is at the top of the stack. When a subroutine is executed, the number of parameters passed is pushed onto BASH_ARGC. The shell sets BASH_ARGC only when in extended debugging mode (see the description of the extdebug option to the shopt builtin in the bash man page).

5. `BASH_ARGV`
   - An array variable containing all the parameters in the current bash execution call stack. The final parameter of the last subroutine call is at the top of the stack; the first parameter of the initial call is at the bottom. When a subroutine is executed, the parameters supplied are pushed onto BASH_ARGV. The shell sets BASH_ARGV only when in extended debugging mode (see the description of the extdebug option to the shopt builtin in the bash man page).

6. `BASH_CMDS`
   - An associative array variable whose members correspond to the internal hash table of commands as maintained by the hash builtin. Elements added to this array appear in the hash table; unsetting array elements causes commands to be removed from the hash table.

7. `BASH_COMMAND`
   - The command currently being executed or about to be executed, unless the shell is executing a command as the result of a trap, in which case it is the command executing at the time of the trap.

8. `BASH_EXECUTION_STRING`
   - The command argument to the `-c` invocation option.

9. `BASH_LINENO`
   - An array variable whose members are the line numbers in source files corresponding to each member of FUNCNAME. `${BASH_LINENO[$i]}` is the line number in the source file where `${FUNCNAME[$i]}` was called (or `${BASH_LINENO[$i-1]}` if referenced within another shell function). The corresponding source file name is `${BASH_SOURCE[$i]}`. Use LINENO to obtain the current line number.

10. `BASH_REMATCH`
    - An array variable whose members are assigned by the =~ binary operator to the [[ conditional command. The element with index 0 is the portion of the string matching the entire regular expression. The element with index n is the portion of the string matching the nth parenthesized subexpression. This variable is read-only.

11. `BASH_SOURCE`
    - An array variable whose members are the source file names corresponding to the elements in the FUNCNAME array variable.

12. `BASH_SUBSHELL`
    - Incremented by one each time a subshell or subshell environment is spawned. The initial value is 0.

13. `BASH_VERSINFO`

    - A read-only array variable whose members hold version information for this instance of bash. The values assigned to the array members are as follows:

    ```bash
    BASH_VERSINFO[0]: The major version number (the release)
    BASH_VERSINFO[1]: The minor version number (the version)
    BASH_VERSINFO[2]: The patch level
    BASH_VERSINFO[3]: The build version
    BASH_VERSINFO[4]: The release status (e.g., beta1)
    BASH_VERSINFO[5]: The value of MACHTYPE
    ```

14. `BASH_VERSION`

    - Expands to a string describing the version of this instance of bash.

15. `COMP_CWORD`

    - An index into ${COMP_WORDS} of the word containing the current cursor position. This variable is available only in shell functions invoked by the programmable completion facilities (see "Programmable Completion" in the bash man page).

16. `COMP_KEY`

    - The key (or final key of a key sequence) used to invoke the current completion function.

17. `COMP_LINE`

    - The current command line. This variable is available only in shell functions and external commands invoked by the programmable completion facilities (see "Programmable Completion" in the bash man page).

18. `COMP_POINT`

    - The index of the current cursor position relative to the beginning of the current command. If the current cursor position is at the end of the current command, the value of this variable is equal to ${#COMP_LINE}. This variable is available only in shell functions and external commands invoked by the programmable completion facilities (see "Programmable Completion" in the bash man page).

19. `COMP_TYPE`

    - Set to an integer value corresponding to the type of completion attempted that caused a completion function to be called: TAB for normal completion, ? for listing completions after successive tabs, ! for listing alternatives on partial word completion, @ to list completions if the word is not unmodified, or % for menu completion. This variable is available only in shell functions and external commands invoked by the programmable completion facilities (see "Programmable Completion" in the bash man page).

20. `COMP_WORDBREAKS`

    - The set of characters that the readline library treats as word separators when performing word completion. If COMP_WORDBREAKS is unset, it loses its special properties, even if it is subsequently reset.

21. `COMP_WORDS`

    - An array variable (see "Arrays" in the bash man page) consisting of the individual words in the current command line. The line is split into words as readline would split it, using COMP_WORDBREAKS as described previously. This variable is available only in shell functions invoked by the programmable completion facilities (see "Programmable Completion" in the bash man page).

22. `DIRSTACK`

    - An array variable (see "Arrays" in the bash man page) containing the current contents of the directory stack. Directories appear in the stack in the order they are displayed by the dirs builtin. Assigning to members of this array variable may be used to modify directories already in the stack, but the pushd and popd builtins must be used to add and remove directories. Assignment to this variable will not change the current directory. If DIRSTACK is unset, it loses its special properties, even if it is subsequently reset.

23. `EUID`

    - Expands to the effective user ID of the current user, initialized at shell startup. This variable is read-only.

24. `FUNCNAME`

    - An array variable containing the names of all shell functions currently in the execution call stack. The element with index 0 is the name of any currently executing shell function. The bottom-most element is main. This variable exists only when a shell function is executing. Assignments to FUNCNAME have no effect and return an error status. If FUNCNAME is unset, it loses its special properties, even if it is subsequently reset.

25. `GROUPS`

    - An array variable containing the list of groups of which the current user is a member. Assignments to GROUPS have no effect and return an error status. If GROUPS is unset, it loses its special properties, even if it is subsequently reset.

26. `HISTCMD`

    - The history number, or index in the history list, of the current command. If HISTCMD is unset, it loses its special properties, even if it is subsequently reset.

27. `HOSTNAME`

    - Automatically set to the name of the current host.

28. `HOSTTYPE`

    - Automatically set to a string that uniquely describes the type of machine on which bash is executing. The default is system-dependent.

29. `LINENO`

    - Each time this parameter is referenced, the shell substitutes a decimal number representing the current sequential line number (starting with 1) within a script or function. When not in a script or function, the value substituted is not guaranteed to be meaningful. If LINENO is unset, it loses its special properties, even if it is subsequently reset.

30. `MACHTYPE`

    - Automatically set to a string that fully describes the system type on which bash is executing, in the standard GNU cpu-company-system format. The default is system-dependent.

31. `OLDPWD`

    - The previous working directory as set by the cd command.

32. `OPTARG`

    - The value of the last option argument processed by the getopts builtin command (see "Shell Builtin Commands" in the bash man page).

33. `OPTIND`

    - The index of the next argument to be processed by the getopts builtin command (see "Shell Builtin Commands" in the bash man page).

34. `OSTYPE`

    - Automatically set to a string that describes the operating system on which bash is executing. The default is system-dependent.

35. `PIPESTATUS`

    - An array variable (see "Arrays" in the bash man page) containing a list of exit status values from the processes in the most recently executed foreground pipeline (which may contain only a single command).

36. `PPID`

    - The process ID of the shell’s parent. This variable is read-only.

37. `PWD`

    - The current working directory as set by the cd command.

38. `RANDOM`

    - Each time this parameter is referenced, a random integer between 0 and 32767 is generated. The sequence of random numbers may be initialized by assigning a value to RANDOM. If RANDOM is unset, it loses its special properties, even if it is subsequently reset.

39. `REPLY`

    - Set to the line of input read by the read builtin command when no arguments are supplied.

40. `SECONDS`

    - Each time this parameter is referenced, the number of seconds since shell invocation is returned. If a value is assigned to SECONDS, the value returned upon subsequent references is the number of seconds since the assignment plus the value assigned. If SECONDS is unset, it loses its special properties, even if it is subsequently reset.

41. `SHELLOPTS`

    - A colon-separated list of enabled shell options. Each word in the list is a valid argument for the -o option to the set builtin command (see "Shell Builtin Commands" in the bash man page). The options appearing in SHELLOPTS are those reported as on by set -o. If this variable is in the environment when bash starts up, each shell option in the list will be enabled before reading any startup files. This variable is read-only.

42. `SHLVL`

    - Incremented by one each time an instance of bash is started.

43. `UID`

    - Expands to the user ID of the current user, initialized at shell startup. This variable is read-only.

---

> The following variables are used by the shell. In some cases, bash assigns a default value to a variable; these cases are noted in the following sections.

---

1. `BASH_ENV`
   - If this parameter is set when bash is executing a shell script, its value is interpreted as a file name containing commands to initialize the shell, as in ~/.bashrc. The value of BASH_ENV is subjected to parameter expansion, command substitution, and arithmetic expansion before being interpreted as a file name. PATH is not used to search for the resultant file name.
2. `CDPATH`
   - The search path for the cd command. This is a colon-separated list of directories in which the shell looks for destination directories specified by the cd command. A sample value is .:~:/usr.
3. `COLUMNS`
   - Used by the select builtin command to determine the terminal width when printing selection lists. This is automatically set upon receipt of a SIGWINCH.
4. `COMPREPLY`
   - An array variable from which bash reads the possible completions generated by a shell function invoked by the programmable completion facility (see "Programmable Completion" in the bash man page).
5. `EMACS`
   - If bash finds this variable in the environment when the shell starts with value t, it assumes that the shell is running in an emacs shell buffer and disables line editing.
6. `FCEDIT`
   - The default editor for the fc builtin command.
7. `FIGNORE`
   - A colon-separated list of suffixes to ignore when performing file name completion (see READLINE in the bash man page). A file name whose suffix matches one of the entries in FIGNORE is excluded from the list of matched file names. A sample value is .o:~.
8. `GLOBIGNORE`
   - A colon-separated list of patterns defining the set of file names to be ignored by pathname expansion. If a file name matched by a pathname expansion pattern also matches one of the patterns in GLOBIGNORE, it is removed from the list of matches.
9. `HISTCONTROL`
   - A colon-separated list of values controlling how commands are saved on the history list. If the list of values includes ignorespace, lines that begin with a space character are not saved in the history list. A value of ignoredups causes lines matching the previous history entry to not be saved. A value of ignoreboth is shorthand for ignorespace and ignoredups. A value of erasedups causes all previous lines matching the current line to be removed from the history list before that line is saved. Any value not in the previous list is ignored. If HISTCONTROL is unset or does not include a valid value, all lines read by the shell parser are saved on the history list, subject to the value of HISTIGNORE. The second and subsequent lines of a multiline compound command are not tested and are added to the history regardless of the value of HISTCONTROL.
10. `HISTFILE`
    - The name of the file in which command history is saved (see HISTORY in the bash man page). The default value is ~/.bash_history. If unset, the command history is not saved when an interactive shell exits.
11. `HISTFILESIZE`
    - The maximum number of lines contained in the history file. When this variable is assigned a value, the history file is truncated, if necessary, by removing the oldest entries to contain no more than that number of lines. The default value is 500. The history file is also truncated to this size after writing it when an interactive shell exits.
12. `HISTIGNORE`
    - A colon-separated list of patterns used to decide which command lines should be saved on the history list. Each pattern is anchored at the beginning of the line and must match the complete line (no implicit \* is appended). Each pattern is tested against the line after the checks specified by HISTCONTROL are applied. In addition to the normal shell pattern matching characters, & matches the previous history line. & may be escaped using a backslash; the backslash is removed before attempting a match. The second and subsequent lines of a multiline compound command are not tested and are added to the history regardless of the value of HISTIGNORE.
13. `HISTSIZE`
    - The number of commands to remember in the command history (see HISTORY in the bash man page). The default value is 500.
14. `HISTTIMEFORMAT`
    - If this variable is set and not null, its value is used as a format string for strftime(3) to print the time stamp associated with each history entry displayed by the history builtin. If this variable is set, time stamps are written to the history file so they may be preserved across shell sessions. This uses the history comment character to distinguish timestamps from other history lines.
15. `HOME`
    - The home directory of the current user; the default argument for the cd builtin command. The value of this variable is also used when performing tilde expansion.
16. `HOSTFILE`
    - Contains the name of a file in the same format as /etc/hosts that should be read when the shell needs to complete a hostname. The list of possible hostname completions may be changed while the shell is running; the next time hostname completion is attempted after the value is changed, bash adds the contents of the new file to the existing list. If HOSTFILE is set but has no value, bash attempts to read /etc/hosts to obtain the list of possible hostname completions. When HOSTFILE is unset, the hostname list is cleared.
17. `IFS`
    - The Internal Field Separator that is used for word splitting after expansion and to split lines into words with the read builtin command. The default value is ''''.
18. `IGNOREEOF`
    - Controls the action of an interactive shell on receipt of an EOF character as the sole input. If set, the value is the number of consecutive EOF characters that must be typed as the first characters on an input line before bash exits. If the variable exists but does not have a numeric value or does not have a value, the default value is 10. If it does not exist, EOF signifies the end of input to the shell.
19. `INPUTRC`
    - The file name for the readline startup file, overriding the default of ~/.inputrc (see READLINE in the bash man page).
20. `LANG`
    - Used to determine the locale category for any category not specifically selected with a variable starting with LC\_.
21. `LC_ALL`
    - This variable overrides the value of LANG and any other LC\_ variable specifying a locale category.
22. `LC_COLLATE`
    - This variable determines the collation order used when sorting the results of pathname expansion and determines the behavior of range expressions, equivalence classes, and collating sequences within pathname expansion and pattern matching.
23. `LC_CTYPE`
    - This variable determines the interpretation of characters and the behavior of character classes within pathname expansion and pattern matching.
24. `LC_MESSAGES`
    - This variable determines the locale used to translate double-quoted strings preceded by a $.
25. `LC_NUMERIC`
    - This variable determines the locale category used for number formatting.
26. `LINES`
    - Used by the select builtin command to determine the column length for printing selection lists. This is automatically set upon receipt of a SIGWINCH.
27. `MAIL`
    - If this parameter is set to a file name and the MAILPATH variable is not set, bash informs the user of the arrival of mail in the specified file.
28. `MAILCHECK`
    - Specifies how often (in seconds) bash checks for mail. The default is 60 seconds. When it is time to check for mail, the shell does so before displaying the primary prompt. If this variable is unset or set to a value that is not a number greater than or equal to zero, the shell disables mail checking.
29. `MAILPATH`

    - A colon-separated list of file names to be checked for mail. The message to be printed when mail arrives in a particular file may be specified by separating the file name from the message with a ?. When used in the text of the message, $\_ expands to the name of the current mail file. Here’s an example:

    ```sh
    MAILPATH='/var/mail/bfox?"You have mail":~/shell-mail?"$_ has mail!"'
    ```

    > Bash supplies a default value for this variable, but the location of the user mail files that it uses is system dependent (for example, /var/mail/$USER).

30. `OPTERR`
    - If set to the value 1, bash displays error messages generated by the getopts builtin command (see "Shell Builtin Commands" in the bash man page). OPTERR is initialized to 1 each time the shell is invoked or a shell script is executed.
31. `PATH`
    - The search path for commands. It is a colon-separated list of directories in which the shell looks for commands (see "Command Execution" in the bash man page). A zero-length (null) directory name in the value of PATH indicates the current directory. A null directory name may appear as two adjacent colons or as an initial or trailing colon. The default path is system-dependent and is set by the administrator who installs bash. A common value is /usr/gnu/bin:/usr/local/bin:/usr/ucb:/bin:/usr/bin.
32. `POSIXLY_CORRECT`
    - If this variable is in the environment when bash starts, the shell enters POSIX mode before reading the startup files, as if the --posix invocation option had been supplied. If it is set while the shell is running, bash enables POSIX mode, as if the command set -o posix had been executed.
33. `PROMPT_COMMAND`
    - If set, the value is executed as a command prior to issuing each primary prompt.
34. `PROMPT_DIRTRIM`
    - If set to a number greater than zero, the value is used as the number of trailing directory components to retain when expanding the \w and \W prompt string escapes (see "Prompting" in the bash man page). Characters removed are replaced with an ellipsis.
35. `PS1`
    - The value of this parameter is expanded (see "Prompting" in the bash man page) and used as the primary prompt string. The default value is `"\s-\v\$ "`.
36. `PS2`
    - The value of this parameter is expanded as with PS1 and used as the secondary prompt string. The default is `"> "`.
37. `PS3`
    - The value of this parameter is used as the prompt for the select command (see "SHELL GRAMMAR" earlier).
38. `PS4`
    - The value of this parameter is expanded as with PS1, and the value is printed before each command bash displays during an execution trace. The first character of PS4 is replicated multiple times, as necessary, to indicate multiple levels of indirection. The default is "`+` ".
39. `SHELL`
    - The full pathname to the shell is kept in this environment variable. If it is not set when the shell starts, bash assigns to it the full pathname of the current user’s login shell.
40. `TIMEFORMAT`
    - The value of this parameter is used as a format string specifying how the timing information for pipelines prefixed with the time reserved word should be displayed. The `%` character introduces an escape sequence that is expanded to a time value or other information. The escape sequences and their meanings are as follows; the braces denote optional portions.
      - `%%`: A literal `%.`
      - `%[p][l]R`: The elapsed time in seconds.
      - `%[p][l]U`: The number of CPU seconds spent in user mode.
      - `%[p][l]S`: The number of CPU seconds spent in system mode.
      - %P: The CPU percentage, computed as (%U + %S) / %R.
        - The optional p is a digit specifying the precision, the number of fractional digits after a decimal point.
        - A value of 0 causes no decimal point or fraction to be output.
        - At most three places after the decimal point may be specified; values of p greater than 3 are changed to 3.
        - If p is not specified, the value 3 is used.
        - The optional `l` specifies a longer format, including minutes, of the form `MMmSS.FFs`. The value of p determines whether the fraction is included.
        - If this variable is not set, bash acts as if it had the value `$'\nreal\t%3lR\nuser\t%3lU\nsys%3lS'`. If the value is `null`, no timing information is displayed. A trailing newline is added when the format string is displayed.
41. `__TMOUT__`
    - If set to a value greater than zero, TMOUT is treated as the default timeout for the read builtin. The select command terminates if input does not arrive after TMOUT seconds when input is coming from a terminal. In an interactive shell, the value is interpreted as the number of seconds to wait for input after issuing the primary prompt. Bash terminates after waiting for that number of seconds if input does not arrive.
42. `__TMPDIR__`
    - If set, bash uses its value as the name of a directory in which bash creates temporary files for the shell’s use.
43. `auto_resume1`
    - This variable controls how the shell interacts with the user and job control. If this variable is set, single word simple commands without redirections are treated as candidates for resumption of an existing stopped job. There is no ambiguity allowed; if there is more than one job beginning with the string typed, the job most recently accessed is selected. The name of a stopped job, in this context, is the command line used to start it. If set to the value exact, the string supplied must match the name of a stopped job exactly; if set to substring, the string supplied needs to match a substring of the name of a stopped job. The substring value provides functionality analogous to the %? job identifier (see "Job Control" in the bash man page). If set to any other value, the supplied string must be a prefix of a stopped job’s name; this provides functionality analogous to the %string job identifier.
44. `histchars`
    - The two or three characters that control history expansion and tokenization (see "History Expansion" in the bash man page). The first character is the history expansion character, the character that signals the start of a history expansion, normally !. The second character is the quick substitution character, which is used as shorthand for rerunning the previous command entered, substituting one string for another in the command. The default is ^. The optional third character is the character that indicates that the remainder of the line is a comment when found as the first character of a word, normally #. The history comment character causes history substitution to be skipped for the remaining words on the line. It does not necessarily cause the shell parser to treat the rest of the line as a comment.
