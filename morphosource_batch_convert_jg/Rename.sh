#!/bin/bash
set -e
set -u
set -o pipefail
echo "Working"
if test -f filenames.txt
then
    rm filenames.txt
fi
ls ./zips/ > filenames.txt
cat filenames.txt
echo "Enter filenames.txt"
read file
while IFS= read -r line
do
    if test "!" -d ./unzips
    then
        mkdir ./unzips
    else
        echo "unzips exists"
    fi
    if test "!" -d ./ToUpload
    then
	mkdir ./ToUpload
    else
	echo "ToUpload exists"
    fi
    echo $line
    unzip -q ./zips/$line -d ./unzips/
    if test -f ./unzips/Info.txt
    then
        dos2unix ./unzips/Info.txt
        Sorce=$(awk '/^Sorce: / {print $2}' ./unzips/Info.txt) 
        CatNum=$(awk '/^SorceID:/ {print $3}' ./unzips/Info.txt)
        Source=${Sorce%$'\r'}
        Number=${CatNum%$'\r'}	
        echo $Source
        echo $Number
    else
        echo "Info.txt not found"
    fi
    if [[ $Sorce == "UWFC" ]]
    then
        Museum="Uwfc"
        Collection="A"
        echo $Museum
        echo $Collection
    else
        echo "Not UWFC"
    fi
    name="${Museum}-${Collection}-${Number}_body"
    jpgname="${name}_"
    mv ./unzips/*.log ./ToUpload/"${name}.log"
    unzip -q ./unzips/Stack.zip -d ./unzips/"${name}"
    for f in ./unzips/"${name}"/*.jpg ; do mv $f ${f//Image/$jpgname} ; done
    mv ./unzips/"${name}" .
    zip -q -r ./"${name}.zip" ./"${name}" 
    mv ./"${name}.zip" ToUpload/
    rm -r ./"${name}"
    rm -r unzips/
    rm ./zips/$line
done < $file
ls ToUpload/
