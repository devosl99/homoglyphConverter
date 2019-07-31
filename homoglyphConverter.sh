#!/bin/bash

#Luke De Vos
#EVL Labs
#Script standardizes glyph representation across encodings
#To use:
#	$./homoglyphConverter.sh [fileToBeConverted].txt
#Output written to [inputName].fit.txt
#Unrecognized character(s) written to unrecognized.txt
#Newlines not preserved

in=$1
filename=$(echo $in | awk -F "/" '{ print $NF }')	#input may be a path. filename is just the file's name, no path
out="output.txt"
temp=$(mktemp /tmp/fittertmp.XXXXXX) 
if ! [ -d "CONVERTED" ]				#if a directory "converted" doesn't exist, make it
then
	mkdir CONVERTED
fi

#swap() searches $out for first argument, replaces with second arg if found
swap () {
	if ! [ -z "$(grep -o "$1" $out)" ]	#-z = empty
	then
		#echo ">Replaced \"$1\" with \"$2\""
		sed "s/$1/$2/g" $out > $temp
		update
	fi
}

#update writes $temp to $out and outputs the contents of $out
#must follow a statement writing to $temp
update () {
	cat $temp > $out
	#cat $out
	
}

#Begin====================================================================================


#Writes selection to $out, necessary for swap() to work moving forward
cat $in > selection.txt
cat selection.txt > $out
echo ""

echo "... $in ..."

#Pre-formatting
#echo ">Octal Dump"
od -An -c $out > $temp
update

#content must be on one line; sed reads line by line
#echo ">Delete new lines"
cat $out | tr -d '\n'  > $temp
update

#Symbol by symbol conversion
swap '\\r  \\n' '\n'
swap '\\n' '\n'
swap " 342 200 230" "'"
swap " 342 200 231" "'"
swap " 342 200 234" "\""
swap " 342 200 235" "\""
swap " 342 200 224" "--"
swap " 342 200 257" ""
swap " 342 200 211" ""	
swap " 342 200 246" "…"
swap " 342 204 242" "™"

swap " 303 261" "ñ"
swap " 303 244" "ä"
swap " 303 251" "é"
swap " 303 257" "ï"
swap " 303 211" "É"
swap " 303 216" "Î"
swap " 303 240" "à"
swap " 303 247" "ç"
swap " 303 250" "è"
swap " 303 252" "ê"
swap " 303 264" "ô"
swap " 342 200" "--"

swap " 221" "'"
swap " 222" "'"
swap " 223" "\""
swap " 224" "\""
swap " 227" "--"
swap " 205" "..."
swap " 342" "â"
swap " 350" "è"
swap " 364" "ô"
swap " 351" "é"
swap " 346" "æ"
swap " 361" "ñ"

#Store unconverted symbols to be displayed for the user
if ! [ -z "$(egrep -o '[0-9]{3,} [0-9]{3,} [0-9]{3,}|[0-9]{3,} [0-9]{3,}|[0-9]{3,}' $out)" ]
then
	echo $filename >> unrecognized.txt
	egrep -o '[0-9]{3,} [0-9]{3,} [0-9]{3,}|[0-9]{3,} [0-9]{3,}|[0-9]{3,}' $out | sort | uniq >> unrecognized.txt
fi

#The above line must execute before instances of 3 adjacent spaces are removed so that it does not remove normal digits in text
#due to how od -An -c formats the output

#Info and input-specific output file
if [ -z "$(egrep -o '[0-9]{3,} [0-9]{3,} [0-9]{3,}|[0-9]{3,} [0-9]{3,}|[0-9]{3,}' $out)" ]
then
	echo ">No unrecognized symbols found"
	
else
	echo ">Unrecognized symbols written to unrecognized.txt"
fi

#Post-formatting
#echo ">Remove instances of 3 adjacent spaces" #caused by od command
sed 's/[[:space:]][[:space:]][[:space:]]//g' $out > $temp
update
swap "^ " ""	#what causes leading space?


#write fitted text to file with name specific to input file's name
cat $out > "CONVERTED/$filename"

#Clean up
rm $temp
rm selection.txt
rm $out

echo "Done."

#echo ">Selected text written to selection.txt"		#currently have selection.txt removed by end of script
#echo ">Fitted text written to $out"			#currently have $out removed by end of script
#echo ">Fitted text written to $in.fit"			#changing things too often, fix when things stop changing

