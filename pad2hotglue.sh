#!/bin/bash

ACCESS=`head -n 1 ./ftp.conf`
HOST=`tail -n 1 ./ftp.conf`

hotglueContent=hotglue/content/test1/head


YPOS=50
WIDTH=550
HEIGHT=0

TMPDIR=tmp
rm $TMPDIR/*.md
echo "delete $hotglueContent/1*" >> ftp.temp


PADDUMP=pad.md
PADURL=http://note.pad.constantvzw.org:8000/p/interviews.tools-of-the-trade/export/txt
PADHTML=pad.html
wget --no-check-certificate -O $PADDUMP  $PADURL

#pandoc pad.md -f markdown -t html -s -o pad.html
#cat $PADDUMP | grep -v ^% | pandoc -r markdown -w html >> $PADHTML

#grep "% NOWSPEAKING:" pad.md | cut -d ":"  -f2 |  sed 's/ //g'| sort | uniq 

  echo "$ACCESS" >ftp.temp


FILE=1000
if [ -f $FILE ]; then rm $FILE ; fi




for LINE in `cat $PADDUMP | sed 's/ /djqteDF34/g'`
do
 
 
 
 LINE=`echo $LINE | sed 's/djqteDF34/ /g' | sed -e 's/<blockquote>/<i>/' -e 's/<\/blockquote>/<\/i>/' -e 's/<strong>/<b>/' -e 's/<\/i>\n<\/p>/<\/i><\/p>/' -e 's/<\/p>\n<i>/<p><i>/' -e 's/<\/strong>/<\/b>/'  -e 's/ % ---------------------------- /\n/'  -e 's//n\//'`
 CHECK=$(echo "$LINE" |grep "% NOWSPEAKING:" | wc -l )


  if [ $CHECK -gt 0 ]
  then
 	
YPOS=$(python -c "print ${YPOS}+${HEIGHT}-40")
NBRCARAC=$(wc -m < "$FILE")
LINENUMBER=$(python -c "print ${NBRCARAC}/65")
HEIGHT=$(python -c "print ${LINENUMBER}*15")
BOXCOLOR=255,255,255

MAXPERLINE=70

echo "type:text"  											>  $FILE
echo "module:text"  											>> $FILE
echo "object-height:${HEIGHT}px"    							>>  $FILE
echo "object-left:${XPOS}px"									>>  $FILE
echo "object-top:${YPOS}px" 										>>  $FILE
echo "object-width:${WIDTH}px"  								>>  $FILE
echo "object-zindex:100" 									>>  $FILE
echo "text-background-color:rgb(${BOXCOLOR})"  		>>  $FILE
echo "text-font-family:'Courier New',Courier,monospace"  >>  $FILE
#echo "text-padding-x:2px"												>>  $FILE
#echo "text-padding-y:2px"										>>  $FILE
echo "text-font-color:rgb(0, 0, 0)"							>>  $FILE
echo "text-font-size:13px"										>>  $FILE
echo ""															>>  $FILE

cat ${FILE}.tmp | grep -v ^% | pandoc -r markdown -w html >> $FILE
rm ${FILE}.tmp




 	
 FILE=`expr $FILE + 1`



echo "put $FILE $hotglueContent/${FILE}" >> ftp.temp
echo "chmod 666 $hotglueContent/${FILE}" >> ftp.temp











echo "$FILE"


 
 fi  



  echo "$LINE"  >>  ${FILE}.tmp


done








echo "bye"  >>ftp.temp

ftp -i -p -n $HOST < ftp.temp

exit 0