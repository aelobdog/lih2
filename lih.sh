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

# TODO: explore the option of modifying the lih script on the first run
#       to add a delclaration with the blog name. This will make cause
#       problems in name changing but all that can be automated so that
#       is not that big of a problem.

usage() {
   echo "usage:"
   echo "./lih.sh <command>"
   echo "\ncommands:"
   echo "   init [blog-name]    creates the directory structure"
   echo "   new  [blog-name]    create a new post"
   echo "   make [blog-name]    compile the blog"
}

init() {
   name=`pwd | awk -F "/" '{print $NF}'`
   if [ -d "$name" ]; then
      echo "ERROR : directory '$name' already exists."
      exit 1
   fi
   mkdir $name && cd $name
   mkdir posts
   mkdir composts
   cd ..
   mkdir templates
   echo "done."
}

new() {
   name=`pwd | awk -F "/" '{print $NF}'`
   printf 'POST TITLE: '
   read -r title
   post_title=$title
   title=`echo $title | sed "s/ /-/g"`
   date=`date '+%Y%m%d'`
   indate=`date '+%d-%m-%Y'`
   filename="$title""_""$date"
   header="# @[❮](../../index.html) ""$post_title"
   echo $header > ./$name/posts/$filename
   echo "#### ""$indate" >> ./$name/posts/$filename
   nvim ./$name/posts/$filename
}

make() {
   bname=`pwd | awk -F "/" '{print $NF}'`
   if [ ! -d "$bname" ]; then
      echo "ERROR : directory '$bname' does not exist."
      exit 1
   fi

   for file in $( ls $bname/posts/ )
   do
      # extract date (and id if there is more than one post on the same day)
      dateID=`echo $file | cut -d "_" -f2 | cut -d "." -f1`
      
      # compile sitefl files to html using default templates
      # store html files in "composts" directory inside blog
      # lih will use the template files in the `template`
      # directory by default, but will fall back on the default
      # sitefl templates if templates dir is empty.

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

      ./sitefl/sitefl -nts $html $css $bname/posts/$file $bname/composts/$dateID.html && echo "LOG : compiled post $file to html."
   done

   # write blog's name to index (sitefl)
   name=`echo $bname | sed "s/\///g"`
   echo "## $name" > $bname/index

   # iterate over posts (latest first)
   for i in $( ls -r $bname/composts )
   do
      # extract dateID from compiled file's name
      dateID=`echo $i | sed "s/.html//g"`
      # find the file with the same dateID in the posts directory
      filename=`ls $bname/posts/ | grep "$dateID"`
      # extract the title from that post
      title=`echo "$filename" | cut -d "_" -f1 | sed "s/-/ /g"`
      date_fmt=`echo $dateID | sed -n -e "s_\(....\)\(..\)\(..\)_\3-\2-\1_p"`
      # write all links to (sitefl) index file
      echo "#### $date_fmt &nbsp &nbsp @[$title]($name/composts/$i)" >> $bname/index
   done
   
   if [ -f './templates/css.css' ]; then
      css='templates/css.css'
   else
      css='sitefl/defaults/templateCSS.css'
   fi

   if [ -f './templates/html.html' ]; then
      html='templates/html.html'
   else
      html='sitefl/defaults/templateHTML.html'
   fi

   # generate index.html
   ./sitefl/sitefl -nts $html $css $name/index index.html && echo "LOG : index.html created."
   echo "done."
}

if [ "$1" = "init" ]; then
   init $2
elif [ "$1" = "make" ]; then
   make $2
elif [ "$1" = "new" ]; then
   new $2
else
   usage
fi
