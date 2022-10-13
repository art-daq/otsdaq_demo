#!/bin/bash

if ! [ -d ups ];then
  echo "This script should be run from a products directory"
  exit 1
fi
if ! [ -d ../srcs ];then
  echo "srcs Directory not found!"
  exit 2
fi

export PRODUCTS=$PWD:/cvmfs/fermilab.opensciencegrid.org/products/artdaq
source setups

demo_version=v`grep "project" ../srcs/otsdaq_demo/CMakeLists.txt|grep -oE "VERSION [^)]*"|awk '{print $2}'|sed 's/\./_/g'`
defaultQuals=`grep "defaultqual" ../srcs/otsdaq_demo/ups/product_deps|awk '{print $2}'`
equalifier=`echo $defaultQuals|cut -f1 -d:`
squalifier=`echo $defaultQuals|cut -f2 -d:`
build_type_exclude=debug
squal_regex=s1[1-9][^`echo ${squalifier:0-1}`]

product_list=`grep -E 'v[0-9]*_[0-9]*' ../srcs/*/ups/product_deps|cut -d: -f2|grep -v artdaq|grep -v otsdaq|grep -v TRACE|grep -vE '^ *#'|grep -v $squal_regex|awk '{print $1, $2}'|sort|uniq`

function scisoft {   # $1 is package or "" for pkg list
    test $1 = '-m' && { shift; do_m=1; } || do_m=0
    pkg=$1; : NOTE: pkg can have OPTIONAL /version, i.e. cetbuildtools/v5_06_00
    test $# -eq 2 && pkg=$pkg/$2
    if [ $do_m -eq 1 ];then
        baseurl=https://scisoft.fnal.gov/scisoft/bundles
        url=`echo $baseurl/$pkg | sed 's|/$||'`
        urlregex=`echo $url | sed 's|/manifests|/[./]*manifests|;s|/|\\\\/|g'`
        echo "url=$url urlregex=$urlregex" >&2
        lynx -dump $url | sed -n "/$urlregex\/[^/]/{s|/\./|/|;s|^.* $url/|$url/|;s|/$||;p;}";
    else
        baseurl=https://scisoft.fnal.gov/scisoft/packages
        url=`echo $baseurl/$pkg | sed 's|/$||'`
        urlregex=`echo $url | sed 's|/packages|/[./]*packages|;s|/|\\\\/|g'`
        echo "url=$url urlregex=$urlregex" >&2
        lynx -dump $url | sed -n "/$urlregex\/[^/]/{s|/\./|/|;s|^.* $url/|$url/|;s|/$||;p;}";
    fi
}

function dl_scisoft {
    myprod=${1}
    myver=${2}
    myequal=${3}
    mybtype=${4}

    if [ -z ${myprod} ] || [ -z ${myver} ]; then
	echo "You must specify both a product and a version for this function!"
        return
    fi

    upslist=`ups list -aK+ $myprod $myver|grep -v $mybtype|grep -E "NULL|$myequal"|wc -l`
    if [ $upslist -eq 0 ];then
      for tarfile in `scisoft $myprod $myver|egrep "slf?7"|grep -E "noarch|$myequal|x86_64\.tar"|grep -v $mybtype|grep -v sha`;do
        curl $tarfile|tar -jxf -
      done
    fi
}

ifs_save=$IFS
IFS=$'\n'
for product in $product_list;do
    IFS=$ifs_save
    dl_scisoft `echo $product` $equalifier $build_type_exclude
    IFS=$'\n'
done
IFS=$ifs_save
