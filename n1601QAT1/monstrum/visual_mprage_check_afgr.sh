#set default variables
startnum=0
appendOut1=`whoami`
appendOut2=`date +%y_%m_%d_%H_%M_%S`
outfiledir="/import/monstrum2/Users/adrose/t1QA/data/${appendOut1}_qa_logs"
outfile="${outfiledir}/${appendOut1}outfile${appendOut2}.csv"
infile="/import/monstrum2/Users/adrose/t1QA/data/mprageList.txt"
indexfile="${outfiledir}/.indexFile.txt"
if [ ! -d "${outfiledir}" ] ; then
  mkdir ${outfiledir} ; 
fi


if [ ! -e "${indexfile}" ] ; then
  echo ${startnum} > ${indexfile} ; 
fi
startnum=`cat ${indexfile}`

format="+%y/%m/%d_%H:%M:%S::"
#echo $(date $format) Started >>$outfile
echo "num, bblid, scanid, rating, ringing, notes" >> $outfile
u=`whoami`
for i in `tail -n +${startnum} $infile`
do      
	bblid_scanid=`echo $i | cut -d "/" -f 6`
	bblid=`echo $bblid_scanid | cut -d "_" -f 1`
	scanid=`echo $bblid_scanid | cut -d "_" -f 2`
	echo "*********"$bblid,$scanid
	startnum=`echo $startnum + 1 | bc`
	scan=`ls $i 2> /dev/null`

	fslview $scan
	echo "Enter your Rating Options are: 1-Bad , 2-Questionable , 3-Good"
	select rating in \
          "Bad" \
          "Questionable" \
          "Good"
          do
            case "${REPLY}" in
              1) rating=0
                 break
                 ;;
              2) rating=1
                 break
                 ;;
              3) rating=2
                 break
                 ;;
              *) echo "Invalid option"
                 ;;
            esac
        done
        echo "Enter if Ringing was present" $u" Options are: 0-Not Present , 1-Present"
        select ringing in \
          "Not Present" \
          "Present"
          do
            case "${REPLY}" in
              1) ringing=0
                 break
                 ;;
              2) ringing=1
                 break
                 ;;
              *) echo "Invalid option"
                 ;;
            esac
        done
	echo "Enter any comments:"
	read notes
	echo $startnum, $bblid, $scanid, $rating, ${ringing}, $notes>> $outfile
        echo $startnum > ${indexfile}
	
done
echo $(date $format) Finished >>$outfile

