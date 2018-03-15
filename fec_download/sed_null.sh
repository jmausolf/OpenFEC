#sed -i.bak 's/\x0/ /g' $file
tr < $file -d '\000' > tmp.txt
mv tmp.txt $file
#rm downloads/*.bak
