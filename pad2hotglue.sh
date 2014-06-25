#!/bin/bash

  ACCESS=`head -n 1 conf/ftp.conf`
    HOST=`tail -n 1 conf/ftp.conf`
 
  HOTGLUECONTENT=hotglue/content/test1/head

# START VALUES
  XPOS=220 ; YPOS=50
  WIDTH=550 ;  HEIGHT=0
 
  TMPDIR=tmp
  FTPTMP=$TMPDIR/ftp.input
  rm $TMPDIR/*.md
 
# UPLOAD VIA FTP (CONTROL FILE USED LATER)
  echo "$ACCESS"                    >  $FTPTMP
  echo "mdelete $HOTGLUECONTENT/1*" >> $FTPTMP
 
 
  PADDUMP=$TMPDIR/pad.md
  PADURL=http://note.pad.constantvzw.org:8000/p/interviews.tools-of-the-trade/export/txt
  PADHTML=$TMPDIR/pad.html

# DOWNLOAD THE PAD
  wget --no-check-certificate -O $PADDUMP  $PADURL
  pandoc tmp/pad.md -r markdown  -w html -o tmp/pad.html
   
  sed -i 's/% NOWSPEAKING:/% NOWSPEAKING: \n/g'  $PADHTML
 	
  FILENAME=1000
  FILE=$TMPDIR/$FILENAME
  if [ -f $FILE ]; then rm $FILE ; fi



# --------------------------------------------------------------------------- #
# SPLIT THE CONTENT IN SEPARATE PARTS FOR SPEAKERS
# --------------------------------------------------------------------------- #
  for LINE in `cat $PADHTML	 | sed -e 's/ /djqteDF34/g'`
   do
  
    # RESTORE SPACES ON CURRENT LINE
      LINE=`echo $LINE | sed 's/djqteDF34/ /g'`
 
    # WRITE LINE TO TEMPORARY FILE
      echo "$LINE"  >>  ${FILE}.box
 
    # CHECK IF SPEAKER CHANGED
      CHECK=$(echo "$LINE" |grep "<p>% NOWSPEAKING:" | wc -l )
 
    # IF THERE IS A DIFFERENT SPEAKER 
      if [ $CHECK -gt 0 ]
       then
 	
     # START NEW FILE
       FILENAME=`expr $FILENAME + 1 `
       FILE=$TMPDIR/$FILENAME 
 		 
      fi  
      
   done
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# MAKE HOTGLUE FILES/BOXES FOR SEPARATE PARTS
# --------------------------------------------------------------------------- #

  for BOX in `ls $TMPDIR/*.box `
   do
		
      FILE=${BOX%%.*} 
		sed -i '/<p>%/d' $BOX
     	MAXPERLINE=72
      YPOS=$(python -c "print ${YPOS}+${HEIGHT}+30")
      LINENUMBER=`cat $BOX | fold -s -w $MAXPERLINE | wc -l`
      HEIGHT=`expr $LINENUMBER \* 15`
		RL=$(grep RL $BOX)
		FS=$(grep FS $BOX)
		XGUY=$(grep X $BOX)
      BOXCOLOR=$((RANDOM%255))","$((RANDOM%255))","$((RANDOM%255))
      
      if [ -n "$FS" ]
				then
				#BOXCOLOR=0,0,255
				XPOS=220
				WIDTH=550
				MAXPERLINE=72


		elif [ -n "$RL" ]
				then
				#BOXCOLOR=0,255,0
				XPOS=250
				WIDTH=520
				MAXPERLINE=67

		elif [ -n "$XGUY" ]
				then
				#BOXCOLOR=255,0,0
				XPOS=300
				WIDTH=475
				MAXPERLINE=60
		fi
  
    # WRITE HOTGLUE HEADER
      echo "type:text"                                          >  $FILE
      echo "module:text"                                        >> $FILE
      echo "object-height:${HEIGHT}px"                         >> $FILE
      echo "object-left:${XPOS}px"                             >> $FILE
      echo "object-top:${YPOS}px"                              >> $FILE
      echo "object-width:${WIDTH}px"                           >> $FILE
      echo "object-zindex:100"                                  >> $FILE
      echo "text-background-color:rgb(${BOXCOLOR})"             >> $FILE
      echo "text-font-family:'Courier New',Courier,monospace"   >> $FILE
      echo "text-font-size:12px"											 >> $FILE
      echo "text-line-height:15px"											 >> $FILE
      #echo "text-padding-x:2px"                                 >> $FILE
      #echo "text-padding-y:20px"                                 >> $FILE
      echo "text-font-color:rgb(0, 0, 0)"                       >> $FILE
      echo "text-font-size:13px"                                >> $FILE
      echo ""                                                   >> $FILE
 
    # CONVERT COLLECTED LINES TO HTML AND ATTACH TO FILE
      cat ${BOX}| \
      sed -e 's/% ----------------------------//g' -e 's/<blockquote>/<i>/' -e 's/<\/blockquote>/<\/i>/' -e 's/<strong>/<b>/' -e 's/<\/i>\n<\/p>/<\/i><\/p>/' -e 's/<\/p>\n<i>/<p><i>/' -e 's/<\/strong>/<\/b>/' | \
      sed  ':a;N;$!ba;s/>\n/>/g'                          >> $FILE  
     # pandoc -r markdown  -w html                             

		if [ `ls -a $BOX | grep "^" $BOX` ]
		then 
		echo "FOUND"
		else
		echo "MISSED, MOTHERFUCKER"
		fi

      rm ${BOX}

      HOTGLUEFILE=`basename $FILE`
    # UPLOAD VIA FTP (CONTROL FILE USED LATER)
      echo "put $FILE $HOTGLUECONTENT/${HOTGLUEFILE}" >> $FTPTMP
    # CHMOD TO MAKE EDITABLE VIA HOTGLUE/BROWSER
      echo "chmod 666 $HOTGLUECONTENT/${HOTGLUEFILE}" >> $FTPTMP
		

  done



  echo "bye"  >>  $FTPTMP
  ftp -i -p -n $HOST < $FTPTMP

# CLEAN UP
   rm $TMPDIR/*.*


exit 0;
