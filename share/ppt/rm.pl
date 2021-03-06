#############################################################################
#  A simple compatible version of rm( 1 ) written in Perl.
#############################################################################
#
#  Copyright (c) Steve Kemp 1999, skx@tardis.ed.ac.uk
#
#  To do:-
#   Currently the interactive and force options are not handled
#  totally correctly.  According to the man pages for RM the
#  option placement matters, so a -f will override an _earlier_
#  -i, etc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
##############################################################################

# Packages we use.
use strict;
use Getopt::Std;

# Command line arguments, and other variables.
use vars qw( $opt_i $opt_f $opt_r $opt_R $opt_P );
my $arg = 0;

# Get the options.
getOptions();

#
# Process each file named on the command line.
foreach $arg ( @ARGV )
{
    processFile( $arg );
}

#
#  Attempt to process each file / directory named on the command line.
sub processFile()
{
    my  ( $fileName )= @_;

    # See if the file is a directory.
    if ( ( -d $fileName ) && ( $opt_r || $opt_R ))
    {
	# Remove a directory recursively.
	removeDirectory( $fileName );
    }
    elsif ( ( -d $fileName ) && !( $opt_r || $opt_R ) && (!$opt_i ))
    {
	rmdir( $fileName );
    }
    elsif( -f $fileName )
    {
	removeFile( $fileName );
    }
}

#
#  Recursively remove a directory
sub removeDirectory( )
{
    my ( $dirName ) = @_;
    my ( $path );

    unless (opendir(DIR, $dirName))
    {
	warn "Can't open $dirName\n";
	closedir(DIR);
	return;
    }

    foreach (readdir(DIR))
    {
	next if $_ eq '.' || $_ eq '..';
	$path = "$dirName/$_";

	if (-d $path)
	{
	    &removeDirectory($path);
	}
	elsif (-f _)
	{
	    removeFile( $path );
	}
    }
    closedir(DIR);

    rmdir( $dirName );
}

#
#  Remove a file, asking for confirmation, etc, as
# necessary
sub removeFile( $fileName )
{
    my ( $fileName ) = @_;
    my $reply;

    # If its read only, and we're not forcing, and interactive prompt for deletion
    #
    if ( ( ! -w $fileName ) && ( !$opt_f ) && ( $opt_i ))
    {
	print "$fileName: Read-only ? ";
	$reply = <STDIN>;
	if ( $reply =~ /^[Nn]/ )
	{
	    return;
	}
    }
    elsif ( $opt_i )
    {
	print "$fileName: ? ";
	$reply = <STDIN>;
	if ( $reply =~ /^[Nn]/ )
	{
	    return;
	}
    }

    # If we are forcing the delete first change the files mode to allow writes.
    if ( $opt_f )
    {
	my ( $mode ) = "0777";
	chmod $mode, $fileName;
    }

    # Overwrite the file with rubbish before deleting.
    if ( $opt_P )
    {
	overWriteFile( $fileName );
    }

    # Delete the file.
    unlink( $fileName );
}

#
# Overwrite the file specified, first with x00, the xFF, then x00
sub overWriteFile( )
{
    my ( $fileName ) = @_;
    # Info returned from stat
    my ( $dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size );
    # Text we print to the file to overwrite its contents
    my ( $text, $FILEHANDLE, $ff );

    # We only want the size
    ( $dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size ) = stat $fileName;

    $ff = "\0xFF";

    # Change mode if the file is readonly.
    if ( !-w $fileName )
    {
	my ( $mode ) = "0777";
	chmod $mode, $fileName;
    }

    ## First pass at overwrite
    if ( open (FILEHANDLE, ">$fileName" ) )
    {
	$text = $ff x $size;
	print FILEHANDLE $text;
	close ( FILEHANDLE );
    }

    ## Second pass at overwrite
    if ( open (FILEHANDLE, ">$fileName" ) )
    {
	$text = "\0" x $size;
	print $text;
	print FILEHANDLE $text;
	close ( FILEHANDLE );
    }

    ## Third  pass at overwrite
    if ( open (FILEHANDLE, ">$fileName" ) )
    {
	$text = $ff x $size;
	print FILEHANDLE $text;
	close ( FILEHANDLE );
    }
}

#
#  Read the options from the command line.
sub getOptions()
{
     # Process options, if any.
     # Make sure defaults are set before returning!
     return unless @ARGV > 0;

     if ( !getopts( 'ifPrR' )  )
     {
	 showUsage();
     }
}

#
# Show the useage
sub showUsage()
{
    print << "E-O-F";
Usage: rm [-fiPrR] file ...
     The options are as follows:

     -f    Attempt to remove the files without prompting for confirmation, re-
           gardless of the file's permissions.  If the file does not exist, do
           not display a diagnostic message or modify the exit status to re-
           flect an error.  The -f option overrides any previous -i options.

     -i    Request confirmation before attempting to remove each file, regard-
           less of the file's permissions, or whether or not the standard in-
           put device is a terminal.  The -i option overrides any previous -f
           options.

     -P    Overwrite regular files before deleting them.  Files are overwrit-
           ten three times, first with the byte pattern 0xff, then 0x00, and
           then 0xff again, before they are deleted.

     -R    Attempt to remove the file hierarchy rooted in each file argument.
           The -R option implies the -d option.  If the -i option is speci-
           fied, the user is prompted for confirmation before each directory's
           contents are processed (as well as before the attempt is made to
           remove the directory).  If the user does not respond affirmatively,
           the file hierarchy rooted in that directory is skipped.

     The rm utility removes symbolic links, not the files referenced by the
     links.

     It is an error to attempt to remove the files ``.'' or ``..''.
E-O-F
    exit;
}
