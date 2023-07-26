nano ShowArgument.sh

bash ShowArguments.sh first second 'third argument'

bash ShowArguments.sh argument1 argument2 'I am argument 3'
bash ShowArguments.sh 'This is how to include "double quotes"'
bash ShowArguments.sh "This is how to include 'single quotes'"

bash ShowArguments.sh {first,second,third}
bash ShowArguments.sh {{1..5},{a..d}}
bash ShowArguments.sh {1..3}{a..b}
bash ShowArguments.sh {01..10..2}
bash ShowArguments.sh {A..G..2}

bash ShowArguments.sh ~
bash ShowArguments.sh ~root

name=Thaddeus
bash ShowArguments.sh "${name}"

bash ShowArguments.sh "$(( 1 + 2 ))" "$(( (1 + 2) * 2 ))"

echo "Today is $( date +%Y-%m-%d )" > file.md
cat file.md

names="Kevin Arthur Evan"
bash ShowArguments.sh $names
bash ShowArguments.sh "$names"

bash ShowArguments.sh Show*
bash ShowArguments.sh ?ile.md
bash ShowArguments.sh [a-f]ile*

bash ShowArguments.sh <(ls -l) >(pr -Tn)

nano OptionTest.sh


bash OptionTest.sh -a
bash OptionTest.sh -v
bash OptionTest.sh -c
bash OptionTest.sh -b

