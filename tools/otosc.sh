code=$(echo $(objdump -D $1 | grep "[0-9a-f]:" | cut -f 2 | sed -r 's/ //g') | sed -r 's/ //g' | sed -r 's/([0-9a-f]{2})/\\x\1/g' )
echo $code | grep "\x00"
echo -e $code > $2
