#!/bin/sh 

arguments=$@
arg="" #input arguments
rc=0   #recursive counter is used to take files and directories from a directory
h=n    #help flag
re=n   #recursive flag
s=n    #subdirectories flag
l=n    #lower casing flag
u=n    #upper casing flag
sen="" #senarios parameter

# function for printing error messages to diagnostic output
error_msg()
{
	echo "error: $1" 1>&2
	exit 1
}

#function for printing help message
help_msg()
{
	cat<<EOT 1>&2

	usage:
	chname  [-r|--recursive] [-s|--subdirectories] [-l|--lowercase|-u|-uppercase] <dir/file names...>
	chname  [-h|--help]
	
	correct syntax examples:

	chname -l File1 FILE2
	chname -u a*
	chname -r -u file1 dir1 dir2 dir3
	chname -r -s -u file1 file2 dir1 dir2

	incorrect syntax example:
	chname -d
EOT
	exit 1
}

# if no arguments given
if test -z "$1"
then
	help_msg
fi


Make_Upper()
{
	mv $1 $(echo $1 | tr "a-z" "A-Z")
}

Make_Lower()
{
	mv $1 $(echo $1 | tr "A-Z" "a-z")
}


while test "$1x" != "x"
do
	case $1
	in
		-h|--help) h=y ;;
		-l|--lowercase) l=y ;;
		-u|--upercase) u=y ;; 
		-r|--recursive) re=y ;;
		-s|--subdirectories) s=y ;;
		*) arg="$arg $1" ;; 
	esac
	shift
done

if [ "$h" = y ]  # if -h flag is yes
then
	help_msg
fi


if [ "$l" = "y" ] && [ "$u" = "y" ]
then
	error_msg "-l and -u cannot be used together. See -h option to get help"
	exit 1
elif [ "$l" = "n" ] && [ "$u" = "n" ]
then
	error_msg "at least one caseing (-l or -u) should be given. Please chech -h option to get help"
	exit 1
fi

if [ "$s" = "n" ] && [ "$re" = "n" ]
then
	sen=1   # only -l|-u
elif [ "$s" = "y" ] && [ "$re" = "n" ]
then
	sen=2   #-l|-u with -s
elif [ "$s" = "n" ] && [ "$re" = "y" ]
then
	sen=3   # -l|-u with -r
elif [ "$s" = "y" ] && [ "$re" = "y" ]
then 
	sen=4   # -l|-u with -r and -s
fi


cn4() # -l -r -s (sen=4)
{

	if [ $rc = "0" ]
	then
    	set $arg
	else
		set $(ls)
	fi
					########### Lower Casing ###########
	if test $l = "y"
	then
		echo "-l is executed"
		while test "$1x" != "x"
    	do
	    	if [ -d "$1" ]
			then	    
         		echo "it is a dir" 
		 		rc=1
		 		cd $1
				cn4
		 		cd ..
		 		Make_Lower $1	#only difference between cn3 and cn4, in cn4 -s is given so directory name should be chamged too
			else
				Make_Lower $1
			fi
	    	shift
     	done
	fi
					########### Lower Casing ###########
	if test $u = "y"
	then
		echo "-u is executed"
	 	while test "$1x" != "x"
     	do
	    	if [ -d "$1" ]
			then	    
         		echo "it is a dir"
		 		rc=1
		 		cd $1
		 		cn4
		 		cd ..
		 		Make_Upper $1	#only difference between cn3 and cn4, in cn4 -s is given so directory name should be chamged too
		 	else
		 		Make_Upper $1
			fi
	    	shift
     	done
	fi
}
 
cn3() # -l -r (sen=3)
{

	if [ $rc = "0" ]
	then
    	set $arg
	else
		set $(ls)
	fi

					########### Lower Casing ###########
	if test $l = "y"
	then
		echo "-l is executed"
		while test "$1x" != "x"
    	do
	    	if [ -d "$1" ]
			then	    
         		echo "it is a dir"  #since -s is not given dont change directory name
		 		rc=1				# make recursive counter 1, check beginning of cn3 function
		 		cd $1
		 		cn3
		 		cd ..
			else
				Make_Lower $1
			fi
	    	shift
     	done
	fi

					########### Upper Casing ###########

	if test $u = "y"
	then
		echo "-u is executed"
	 	while test "$1x" != "x"
     	do
	    	if [ -d "$1" ]
			then	    
         		echo "it is a dir"  #since -s is not given dont change directory name
		 		rc=1                # make recursive counter 1, check beginning of cn3 function
		 		cd $1
		 		cn3
		 		cd ..
		 	else
				Make_Upper $1
			fi
	    	shift
     	done
	fi
}

cn2() # -l -s (sen=2)
{
    set $arg

					########### Lower Casing ###########
	if test $l = "y"
	then
	 	echo "-l is executed"
	 	while test "$1x" != "x"
     	do
        	Make_Lower $1
	    	shift
     	done
	fi

					########### Upper Casing ###########
	if test $u = "y" 
	then
		echo "-u is executed"
		while test "$1x" != "x"
        do
	 		Make_Upper $1
	 		shift
 		done
	fi

}


cn1() # -l (sen=1)
{

    set $arg

					########### Lower Casing ###########
	if test $l = "y"
	then
		echo "-l is executed"
		while test "$1x" != "x"
     	do
	    	if [ -d "$1" ]
			then	    
         		echo "it is a dir"    #since -s is not given dont change directory name
			else
				Make_Lower $1
			fi
	    	shift
     	done
	fi

					########### Upper Casing ###########
	if test $u = "y"
	then
		echo "-u is executed"
		while test "$1x" != "x"
     	do
	    	if [ -d "$1" ]
			then	    
        		echo "it is a dir"  #since -s is not given dont change directory name
			else
				Make_Upper $1
			fi
	    	shift
    	done
	fi

}

case $sen
in
	1) cn1 ;;
	2) cn2 ;; 
	3) cn3 ;;
 	4) cn4 ;;
 	5) error_msg "wrong usage. See -h option to get help" ;;
 	*) ;; 
esac

exit 0
