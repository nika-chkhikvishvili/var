#!/bin/sh

# sum:: top.ge domain extract by category
# for: squid access lists 
# by: Nick Chkhivishvili 
# to: smartlogic 2016
# license: BSD


#Extraxt domains, URLs from top.ge by category. eg:

# ./top.ge-extract.sh -c 23 
# ./top.ge-extract.sh -c "http://www.top.ge/cat.php?c=19&where=Games"
# ./top.ge-extract.sh -c 30 -d



# Progress bar function                      
function progress_start {


### indicator colors
color_start="\033[33;1m" #YELLOW
color_end="\033[0m\033[1m\033[0m" #END YELLOW
progress_start="\033[32;1m" #GREEN
#chars=(  "ᐅ" "ᐃ" "ᐊ" "ᐁ"  )
#chars=( "▶" "◢" "▼" "◣" "◀" "◤" "▲" "◥"   )
#chars=("∘" "◌" "◯" "◎" "◉" "●⦁")
chars=("$color_start◐$color_end" "$color_start◓$color_end" "$color_start◑$color_end" "$progress_start●$color_end$color_start◒$color_end"  )
chars=( "→" "↘"  "↓" "↙" "←" "↖" "↑" "\033[1m\033[0m\033[32;1m↓\033[0m\033[1m\033[0m↗" )

 interval=0.05
  count=0

  while true
  do
    pos=$(($count % 8))

    echo -en "\b${chars[$pos]}"

    count=$(($count + 1))
    sleep $interval
  done
}


# Stop progress indicator
function progress_stop {
  exec 2>/dev/null
  kill $1
  echo -en " +done \n"
}
# END  Progress bar function                 




check_input ()
{

# validate input args
local category=$1
if [[ $(echo $category | grep -oc "top.ge") -eq 1 ]]; then
   #get category id from url
      cat_id=$(echo $category | grep -Po "(?<=cat.php\?c=).*(?=\&)")
       if ! [[ $cat_id =~ ^[0-9]$|^0[1-9]$|^1[0-9]$|^2[0-9]|^30$ ]]; then
       echo "Error. Entered URL is invalid."
       exit 1;
   else
   echo OK. Entered URL is valid. 
   echo category id is: $cat_id
   fi
 

  # validate integer 
elif  [[ $category =~ ^[0-9]$|^0[1-9]$|^1[0-9]$|^2[0-9]|^30$ ]]; then
    cat_id=$category
    echo OK. $cat_id is valid category ID.
else
    echo "Error: input is not a valid " 
    exit 1;
  fi



} 

#usge function
usage() { echo "Usage: $0 [-c <http://top.ge/...|23>]" 1>&2; exit 1; }

while getopts ":c:d" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            check_input $c ||  usage
            ;;
        d)
           d="true"
           echo $d 
            ;;
          
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${c}" ]; then
    usage
fi


cat_id="${c}"




progress_start &
pid=$!

url="http://www.top.ge/cat.php?c=$cat_id"


echo calculating pages...
# get pages count from selected category
get_pages=$(curl -s "$url" |  grep -Po "(?<=.records\sare\sspread\sover\s).*(?=\spages)" |awk NR==1)
echo got $get_pages pages.

echo processing...
sleep 2

while [[ $i -ne $get_pages ]]
 do 
i=$((i+1)) && site_list="$site_list\n $(curl -s "http://www.top.ge/cat.php?pagenr=$i&c=$cat_id" | grep "showhint" | grep -Po "http(?:s)?:\/\/(?:[\w-]+\.)*([\w-]{1,63})(?:\.(?:\w{3}|\w{2}))" )"
done  

progress_stop $pid

if [[ $d == "true" ]]; then 
   echo -e "$site_list" | sed 's/[[:space:]]//g' | grep -Po '(?<=.:\/\/).*' | sed -e 's/\/.*//g'
  else
   echo -e "$site_list" | sed 's/[[:space:]]//g' 
fi
