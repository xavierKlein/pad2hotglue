#!/bin/bash

  ACCESS=`head -n 1 conf/ftp.conf`
    HOST=`tail -n 1 conf/ftp.conf`
 
  HOTGLUECONTENT=hotglue/content/test1/head

# START VALUES
  XPOS=20 ; YPOS=50
  WIDTH=550 ;  HEIGHT=0
 
  TMPDIR=tmp
  FTPTMP=$TMPDIR/ftp.input
  rm $TMPDIR/*.md
 
# UPLOAD VIA FTP (CONTROL FILE USED LATER)
  echo "$ACCESS"                    >  $FTPTMP
  echo "mdelete $HOTGLUECONTENT/1*" >> $FTPTMP
 
 
  PADDUMP=$TMPDIR/pad.md
  PADURL=http://note.pad.constantvzw.org:8000/p/interviews.tools-of-the-trade/export/txt
  PADHTML=${PADDUMP%%.*}.html

# DOWNLOAD THE PAD
  wget --no-check-certificate -O $PADDUMP  $PADURL
 
  FILENAME=1000
  FILE=$TMPDIR/$FILENAME
  if [ -f $FILE ]; then rm $FILE ; fi



# --------------------------------------------------------------------------- #
# SPLIT THE CONTENT IN SEPARATE PARTS FOR SPEAKERS
# --------------------------------------------------------------------------- #
  for LINE in `cat $PADDUMP | sed 's/ /djqteDF34/g'`
   do
  
    # RESTORE SPACES ON CURRENT LINE
      LINE=`echo $LINE | sed 's/djqteDF34/ /g'`
 
    # WRITE LINE TO TEMPORARY FILE
      echo "$LINE"  >>  ${FILE}.box
 
    # CHECK IF SPEAKER CHANGED
      CHECK=$(echo "$LINE" |grep "% NOWSPEAKING:" | wc -l )
 
    # IF THERE IS A DIFFERENT SPEAKER 
      if [ $CHECK -gt 0 ]
       then
 	
     # START NEW FILE
       FILENAME=`expr $FILENAME + 1`
       FILE=$TMPDIR/$FILENAME
 
      fi  
 
   done
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# MAKE HOTGLUE FILES/BOXES FOR SEPARATE PAŔTS
# --------------------------------------------------------------------------- #

  for BOX in `ls $TMPDIR/*.box`
   do

      FILE=${BOX%%.*}

      MAXPERLINE=50
      YPOS=$(python -c "print ${YPOS}+${HEIGHT}+100")
      LINENUMBER=`cat $BOX | grep -v ^% | fold -s -w $MAXPERLINE | wc -l`
      HEIGHT=`expr $LINENUMBER \* 15`

      BOXCOLOR=$((RANDOM%255))","$((RANDOM%255))","$((RANDOM%255))
  
    # WRITE HOTGLUE HEADER
      echo "type:text"                                          >  $FILE
      echo "module:text"                                        >> $FILE
      echo "object-height:${HEIGHT}px"                          >> $FILE
      echo "object-left:${XPOS}px"                              >> $FILE
      echo "object-top:${YPOS}px"                               >> $FILE
      echo "object-width:${WIDTH}px"                            >> $FILE
      echo "object-zindex:100"                                  >> $FILE
      echo "text-background-color:rgb(${BOXCOLOR})"             >> $FILE
      echo "text-font-family:'Courier New',Courier,monospace"   >> $FILE
      echo "text-padding-x:2px"                                 >> $FILE
      echo "text-padding-y:2px"                                 >> $FILE
      echo "text-font-color:rgb(0, 0, 0)"                       >> $FILE
      echo "text-font-size:13px"                                >> $FILE
      echo ""                                                   >> $FILE
 
    # CONVERT COLLECTED LINES TO HTML AND ATTACH TO FILE
      cat ${BOX} | \
      grep -v ^% | \
      pandoc -r markdown -w html                                >> $FILE

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
