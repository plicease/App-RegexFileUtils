# App::RegexFileUtils [![Build Status](https://secure.travis-ci.org/plicease/App-RegexFileUtils.png)](http://travis-ci.org/plicease/App-RegexFileUtils)

use regexes with file utils like rm, cp, mv, ln

# VERSION

version 0.05\_01

# SYNOPSIS

Remove all files with a .bak extension:

    % rerm '/\.bak$/'

Change the extension of all files from .jpeg or .JPG (any case) to .jpg

    % remv '/\.jpe?g$/.jpg/i'

Copy all Perl files to a different directory:

    % recp '/\.p[lm]$/' /perl/lib

Create symlinks to .so files so that the symlinks lack a version number

    % reln -s '/\.so\..*$/.so/'

# DESCRIPTION

This distribution provides a version of `rm`, `cp`, `mv` and `ln` with a _re_ 
(as in regular expression) prefix where the file sources can be specified as a regular
expression, or the file source and destination can be specified as a regular expression 
substitution Perl style.  The functionality that this provides can be duplicated with 
shell syntax (typically for loops), but I find these scripts require less typing and 
work regardless of the shell you are using.

The scripts in this distribution do not remove, copy, move or link files directly, 
instead they call the real `rm`, `cp`, `mv` and `ln` programs provided by your
operating system.  You can therefore use any options that they support, for example
the `-i` option will allow you to interactively delete files:

    % rerm -i '/\.bak$/'

# OPTIONS

In addition to any options supported by the underlying operating system, these scripts
will recognize the following options (and NOT pass them to the underlying system utilities).
They are prefixed with `--re` so that they do not interfear with any "real" options.

## \--recmd command

Specifies the command to execute.  This is usually determined by Perl's $0 variable.

## \--reverbose

Print out the system commands that are actually executed.

## \--reall

Include even hidden dot files, like `.profile` and `.login`.

# METHODS

These commands can also be invoked from your Perl script, using this module:

## App::RegexFileUtils->main( $program, @arguments )

For example:

    use App::RegexFileUtils;
    App::RegexFileUtils->main( 'rm', '/\.bak$/' );

# CAVEATS

You will need to enclose many regular expressions in single
quotes '' on the command line as many regular expression characters
have special meanings in shells.

The underlying fileutils command (rm, cp, ln, etc) will be called
for each file operated on, which may be slow if many files match
the regular expression provided.

This was written a long time ago and the code isn't very modern.

Directories with a training slash may be ambiguous with a regex, so
if you want to use a path as a destination instead of a regex, be
sure you do NOT include the trailing slash.  That is:

    # use this:
    % recp /^foo/ /usr/bin
    # NOT this:
    % recp /^foo/ /usr/bin/

# BUNDLED FILES

This distribution comes bundled with `cp`, `ln`, `rm`, `touch`
from the old [Perl Power Tools](https://metacpan.org/release/ppt) project.
These are only used on `MSWin32` if these commands are not found in
the path as they are frequently not available on that platform.  They
are individually licensed separately.

## cp.pl

This program is copyright by Ken Schumack 1999.

This program is free and open software. You may use, modify, distribute
and sell this program (and any modified variants) in any way you wish,
provided you do not restrict others from doing the same.

## ln.pl

This program is copyright by Abigail 1999.

This program is free and open software. You may use, copy, modify, distribute,
and sell this program (and any modified variants) in any way you wish,
provided you do not restrict others from doing the same.

## rm.pl

Copyright (c) Steve Kemp 1999, skx@tardis.ed.ac.uk

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

## touch.pl

This program is copyright by Abigail 1999.

This program is free and open software. You may use, copy, modify, distribute
and sell this program (and any modified variants) in any way you wish,
provided you do not restrict others to do the same.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
