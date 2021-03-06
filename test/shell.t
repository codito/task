#! /usr/bin/env perl
################################################################################
## taskwarrior - a command line task list manager.
##
## Copyright 2006-2012, Paul Beckingham, Federico Hernandez.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included
## in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##
## http://www.opensource.org/licenses/mit-license.php
##
################################################################################

use strict;
use warnings;
use Test::More tests => 5;

# Create the rc file.
if (open my $fh, '>', 'shell.rc')
{
  print $fh "data.location=.\n",
            "shell.prompt=testprompt>\n",
            "defaultwidth=0\n",
            "default.command=ls\n";
  close $fh;
  ok (-r 'shell.rc', 'Created shell.rc');
}

# Test the prompt.
my $output = qx{echo "quit" | ../src/task rc:shell.rc shell 2>&1};
like ($output, qr/testprompt>/, 'custom prompt is being used');

# Test a simple add, then info.
qx{echo "add foo" | ../src/task rc:shell.rc shell 2>&1};
$output = qx{echo "1 info" | ../src/task rc:shell.rc shell 2>&1};
like ($output, qr/Description\s+foo/, 'add/info working');

unlink 'shell.rc';
ok (!-r 'shell.rc', 'Removed shell.rc');

# Cleanup.
unlink qw(pending.data completed.data undo.data backlog.data synch.key shell.rc);
ok (! -r 'pending.data'   &&
    ! -r 'completed.data' &&
    ! -r 'undo.data'      &&
    ! -r 'backlog.data'   &&
    ! -r 'synch.key'      &&
    ! -r 'shell.rc', 'Cleanup');

exit 0;

