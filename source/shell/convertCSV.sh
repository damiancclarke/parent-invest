for f in *.dbf;
do
dbfdump $f --info | grep '^[0-9]*[\.]' | grep [A-Z_] | awk {'printf "%s;", $2'}  > ./csv/$f.csv;
echo "" >> ./csv/$f.csv;
dbfdump -fs=';' $f >> ./csv/$f.csv;
done

