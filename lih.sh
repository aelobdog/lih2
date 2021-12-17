#!/bin/sh
# ------------------------------------------------------------------------
# Copyright (C) 2021 Ashwin Godbole
# ------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------

usage() {
   echo "usage:"
   echo "sh lih.sh command"
   echo "\ncommands:"
   echo "   init [name]    creates the directory structure"
   echo "   make           compiles blog"
}

init() {
   if [ -d "$1" ]; then
      echo "ERROR : directory '$1' already exists."
      exit 1
   fi
   mkdir $1 && cd $1
   mkdir posts
   mkdir composts
   cd ..
   mkdir templates
   echo "done."
}

new() {
   printf 'POST TITLE: '
   read -r title
   post_title=$title
   title=`echo $title | sed "s/ /-/g"`
   date=`date '+%Y%m%d'`
   filename="$title""_""$date"
   header="# @[❮](../../index.html) ""$post_title"
   echo $header > ./aelobdog-writes/posts/$filename
   vi ./aelobdog-writes/posts/$filename
}

make() {
   if [ ! -d "$1" ]; then
      echo "ERROR : directory '$1' does not exist."
      exit 1
   fi
   
   for file in $( ls $1/posts/ )
   do
      # extract date (and id if there is more than one post on the same day)
      dateID=`echo $file | cut -d "_" -f2`
      
      # compile sitefl files to html using default templates
      # store html files in "composts" directory inside blog

      # lih will use the template files in the `template` directory by default,
      # but will fall back on the default sitefl templates if templates dir is 
      # empty.

      if [ -f './templates/css.css' ]; then
         css='../../templates/css.css'
      else
         css='../../sitefl/defaults/templateCSS.css'
      fi

      if [ -f './templates/html.html' ]; then
         html='./templates/html.html'
      else
         html='./sitefl/defaults/templateHTML.html'
      fi

      ./sitefl/sitefl -nts $html $css $1/posts/$file $1/composts/$dateID.html && echo "LOG : compiled post $file to html."
   done

   # write blog's name to index (sitefl)
   name=`echo $1 | sed "s/\///g"`
   echo "# $name\n" > $1/index

   # iterate over posts (latest first)
   for i in $( ls -r $1/composts )
   do
      # extract dateID from compiled file's name
      dateID=`echo $i | sed "s/.html//g"`
      # find the file with the same dateID in the posts directory
      filename=`ls $1/posts/ | grep "$dateID"`
      # extract the title from that post
      title=`echo "$filename" | cut -d "_" -f1 | sed "s/-/ /g"`
      # write all links to (sitefl) index file
      echo "### @[$title]($name/composts/$i)\n" >> $1/index && echo "LOG : added [ $title ] to index (sitefl)"
   done
   
   # generate index.html
   ./sitefl/sitefl -nts ./sitefl/defaults/templateHTML.html ./sitefl/defaults/templateCSS.css $name/index index.html && echo "LOG : index.html created."
   echo "done."
}

if [ "$1" = "init" ]; then
   init $2
elif [ "$1" = "make" ]; then
   make $2
elif [ "$1" = "new" ]; then
   new
else
   usage
fi
