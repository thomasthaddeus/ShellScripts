# Special Characters in Commands

1. `\` escapes itself and other specials

2. `*` stands for anything (including nothing)

   ```bash
   find ex*.txt
   ```

3. `?` stands for any single character

   ```bash
   find ex?mple.txt
   ```

4. `[]` encloses patterns for matching a single character

   ```bash
   find ex[abc]mple.txt
   ```

5. `()` runs the contents of the parentheses in a sub-shell

   ```bash
   pwd && ( cd /etc) && pwd
     /home/simon
     /home/simon
   ```

6. `;` terminates a command pipeline - use it to separate commands on a single line

   ```sh
   echo Hi ; uname
       Hi
       Linux
   ```

7. `' '` The contents of the single quotes are passed to the command without any interpretation.

   ```sh
   find '(echo abc)'*
   (echo abc).txt
   ```

8. ``` ` The contents of the backquotes are run as a command and its output is used as part of this command

   ```bash
   echo `uname` Linux
   ```

9. `""` The contents of the quotes are treated as one argument;
   - any specials inside the quotes, except for `$` and ` `` `, are left uninterpreted.

   ```bash
   cd "untitled folder"
   ```

`|` Pipes allow you to send the output of a command to another command.
    `$` fortune | cowsay
`&` Run a command in the background.
    `$` cowsay &
`&&` Only execute the second command if the first one was successful.
    `$` ping localhost -c 1 && cowsay great
`||` Only execute the second command if the first one was unsuccessful.
   > $ ping "not.reachable" -c 1 || cowsay sorry
`>>` These symbols are used for redirection.
`!!` Repeat the last command
   > $ sudo !!

`!*` Change command keep all arguments

    $ head history | grep query

    $ !* tail
        tail history | grep query

`^` Quick history substitution, changing one string to another.

   ```bash
   $ ls *.png
   toast.png
   ```

   ```bash
   $ ^png^xcf^
   ls *.xcf
   bread.xcf
   ```

`#` Turns the line into a comment; the line is not processed in any way.

   ```bash
   $ whatis xdotool # hint: has sth todo with X11
   ```
