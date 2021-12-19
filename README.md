# lih2
lih2 is a simple blog creation and maintanance tool

#### _DISCLAIMER_ : This is experimental software.
####                There are bugs.
####                You have been warned. (xP)

## Setting up
Before you can make your blog, you need to get the necessary tools
```bash
$ # make a new directory to store the script and the blog
$ mkdir blog_cover

$ # change directories into the one you just created
$ cd blog_cover

$ # download lih.sh into the directory
$ git clone https://github.com/aelobdog/lih2

$ # extract the files from the downloaded directory
$ mv lih2/lih.sh ./; mv lih2/sitefl/ ./; mv lih2/templates/ ./;
$ rm -rf lih2/
```

## Making a new blog
Making the blog is a single command away now.
```bash
$ ./lih.sh init my_blog_name
```

## Writing your first post
Writing a post is simple as well!
```bash
$ ./lih.sh new my_blog_name
POST TITLE: My first post
<edit the file opened in nvim>
```

## Generating the blog
Now that the post is written, run the following command to
generate the blog index and all the posts.
```bash
$ ./lih.sh make my_blog_name
```

That's it! Happy writing!
