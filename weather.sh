#!/usr/bin/env bash

# weather.sh script by Laurier Rochon
# l@pwd.io

if [ ! -f cities ];
then
    echo "Running for the first time, downloading cities list..."
    wget -qO- --output-document=cities https://s3.amazonaws.com/assets.weather/cities
    echo "Done downloading."
fi

#VARS
NB=$#
FILE=cities

#GET INPUT
if [ $NB -eq 1 ]
then
    A=`awk -F "\t" -v town="$1" 'tolower($3) ~ tolower(town) {print NR}' $FILE`
fi

if [ $NB -eq 2 ]
then
A=`awk -F "\t" -v town="$1" -v state="$2" \
 'tolower($3) ~ tolower(town) && (tolower($2) ~ tolower(state) || tolower($1) ~ tolower(state)) {print NR}' $FILE`
fi

if [ $NB -eq 3 ]
then
A=`awk -F "\t" -v town="$1" -v state="$2" -v country="$3" \
 'tolower($3) ~ tolower(town) && tolower($2) ~ tolower(state) && tolower($1) {print NR}' $FILE`
fi

#make array of results
array=($A)
nbresults=${#array[@]}

showresult(){
    val=`wget -qO- "http://www.weather.com/search/enhancedlocalsearch?where=${url_ready_place}" | \
     awk -F '</span>' '/(wx-value)*(\"temperature-fahrenheit\")/ {print $1;}' | head -1 | tail -c 3`

    phrase=`wget -qO- "http://www.weather.com/search/enhancedlocalsearch?where=${url_ready_place}" | \
     awk -F '</span>' '/(wx-first)/ {getline; getline; getline; getline; print ;}' | head -1`

    section=$(echo $phrase | awk -F "desc=\"" '{print $NF}')
    full_f=`echo $section | sed 's/">//' | sed 's/It...//'`

    parts=`echo $full_f | sed 's/&deg...//'`

    description=""

    STR_ARRAY=(`echo $parts | tr "\t" "\n"`)
 
    temp_far=${STR_ARRAY[0]}

    temp_celcius=$((($temp_far-32)*5/9))

    i=0
    for x in "${STR_ARRAY[@]}"
    do
        if [  $i -gt 0 ]
        then
            description="$description $x"
        fi
        i=$[$i +1]
    done
    url_ready_place_spaces=$(echo $url_ready_place | sed 's/+/ /g')
    d=`echo $description| awk '{print tolower($0)}'`
    echo It\'s currently $temp_celcius°C \($temp_far°F\), $d in $url_ready_place_spaces.
}

#no results
if [  $nbresults -eq 0 ]
then
    echo "No results matched your city. Try another one?"
fi

#single result
if [  $nbresults -eq 1 ]
then
    line_result=`sed -n "${array[0]}"p $FILE`

    city=""

    STR_ARRAY=(`echo $line_result | tr "\t" "\n"`)
 
    i=0
    for x in "${STR_ARRAY[@]}"
    do
        if [  $i -gt 1 ]
        then
            city="$city $x"
        fi
        i=$[$i +1]
    done

    state=$(echo $line_result | awk '{print $2}')
    country=$(echo $line_result | awk '{print $1}')

    #not valid state.
    if [ "$state" -eq "$state" ] 2>/dev/null; then
      state=""
    else
      state=$state
    fi

    place="$city $state $country"
    url_ready_place=$(echo $place | sed 's/ /+/g')
    showresult
fi


parse_from_multiple(){
    if [ "$1" == "None, make a new search" ]
    then
        exit;
    fi

    url_ready_place=$(echo $1 | sed s/\'//g | sed 's/ /+/g')
    showresult
}  

#multiple results
if [  $nbresults -gt 1 ]
then
    echo "Did you mean:"

    choices=()

    for x in "${array[@]}"
    do
        line=$(echo "`sed -n ${x}p ${FILE}`")
        
        state=$(echo $line | awk '{print $2}')
        country=$(echo $line | awk '{print $1}')

        city=""
        STR_ARRAY=(`echo $line | tr "\t" "\n"`)
        i=0
        for x in "${STR_ARRAY[@]}"
        do
            if [  $i -gt 1 ]
            then
                city="$city $x"
            fi
            i=$[$i +1]
        done
        city=$( echo "$city," | cut -c 2-)

        #not valid state.
        if [ "$state" -eq "$state" ] 2>/dev/null; then
          state=""
        else
          state="$state,"
        fi

        place="'$city $state $country'"
        choices+=("$place")
    done

    choices+=("None, make a new search")

    select c in "${choices[@]}"; do parse_from_multiple "${c}"; break; done

fi