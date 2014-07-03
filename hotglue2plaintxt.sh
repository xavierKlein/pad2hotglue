#!/bin/bash

 HOTGLUEURL="http://www.lafkon.net/xk/hotglue/lafuente2"

 HOTGLUEBASE=`echo $HOTGLUEURL | sed 's,/$,,g' | rev | cut -d "/" -f 2- | rev`
 HOTGLUEPAGE=`echo $HOTGLUEURL | sed 's,/$,,g' | rev | cut -d "/" -f 1  | rev`
 HOTGLUECONTENT=${HOTGLUEBASE}/content/${HOTGLUEPAGE}/head/

 TMPDIR=tmp

 cd $TMPDIR
 wget -r -np -nH --no-directories \
      -N -S -R index.html* \
      -A * $HOTGLUECONTENT
 rm robots.txt
 cd -



 WIDTH=200 ; HEIGHT=100 
 CNT=0; while [ $CNT -lt $WIDTH ];  
         do BLANKLINE="${BLANKLINE} ";  
            CNT=`expr $CNT + 1`;  
         done


 for HOTGLUEBOX in `grep "object-top" $TMPDIR/* | \
                    sort -n -t: -k 3,3`
  do 
     HOTGLUEBOX=`echo $HOTGLUEBOX | cut -d ":" -f 1`

     POSITIONEDBOX=${HOTGLUEBOX%%.*}.txt

     XPOS=`grep object-top  $HOTGLUEBOX | cut -d ":" -f 2 | sed 's/px//g'`
   # echo $XPOS
     YPOS=`grep object-left $HOTGLUEBOX | cut -d ":" -f 2 | sed 's/px//g'`
   # echo $YPOS
     WIDTH=`grep object-width $HOTGLUEBOX | cut -d ":" -f 2 | sed 's/px//g'`

     XPOS=`expr $XPOS / 15`
     YPOS=`expr $YPOS / 8`
     WIDTH=`expr $WIDTH / 8`

     INDENT="";CNT=0
     while [ $CNT -lt $YPOS ]; do INDENT="$INDENT "; CNT=`expr $CNT + 1`; done


     CNT=0; if [ -f $POSITIONEDBOX ]; then rm $POSITIONEDBOX ; fi
     while [ $CNT -lt $XPOS ]; 
      do echo "$BLANKLINE" >> $POSITIONEDBOX ;  CNT=`expr $CNT + 1`; 
     done

     if [ `grep "this is: speaker initial" $HOTGLUEBOX | wc -l` -lt 1 ]; then

     cat $HOTGLUEBOX |                # START READING HOTGLUE BOX
     sed -n "/^$/,\$p" |              # PRINT CONTENT ONLY
     sed 's/$/N3WL1Ne/g' |            # SAVE LINEBREAKS
     pandoc -r html -w plain |        # CONVERT TO PLAINTEXT
     recode utf-8..ascii |            # 
     sed ':a;N;$!ba;s/\n/ /g' |       # REMOVE ALL LINEBREAKS
     sed 's/N3WL1Ne/\n/g' |           # RESTORE SAVED LINEBREAKS 
     fold -s -w $WIDTH | \
     sed "s/^/${INDENT} | /" >> $POSITIONEDBOX

     fi


 done


























exit 0;
