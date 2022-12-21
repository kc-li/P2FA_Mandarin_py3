#To generate wordlist
# generate a pure text file
awk '{$1=""}1' list.txt| awk '{$1=$1}1' |awk '{gsub(/"/, "")} 1' > listclean.txt
# generate the wordlist
tr ' ' '\n' < listclean.txt|sed '/^$/d'|sort|uniq -c|sed 's/^ *//'|sed 's/"//'|sort -r -n > wordlist.txt
# I add: sed 's/"//' to remove double quote

# Now we compare to the dictionary files
# First add "^" to the file
cut -d ' ' -f 2 wordlist.txt | sed 's/^/^/'| sed 's/$/ /' >tmp.txt
# match it with the dictionary copy file
egrep --file=tmp.txt dict_copy > words_phones.txt
# remove the duplicate
cat words_phones.txt|uniq -c|sed 's/^ *//' >words_phones2.txt
# find unmatch
sort -k 2 wordlist.txt >tmp1.txt
awk '{print $2}' words_phones2.txt|sort> tmp2.txt
join -v 1 -1 2 -2 1 tmp1.txt tmp2.txt >missingwords.txt
