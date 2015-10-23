tools/otosc.py "$(objdump -Dz $1 | grep "[0-9a-f]:" | cut -f 1,2)" $2
