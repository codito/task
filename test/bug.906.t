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
use Test::More tests => 17;

# Create the rc file.
if (open my $fh, '>', 'bug.rc')
{
  print $fh "data.location=.\n",
            "confirmation=off\n";
  close $fh;
  ok (-r 'bug.rc', 'Created bug.rc');
}

# Bug 906: escaping runs amok
qx{../src/task rc:bug.rc add zero 2>&1};
qx{../src/task rc:bug.rc add one  pro:a.b 2>&1};
qx{../src/task rc:bug.rc add two  pro:a 2>&1};
my $output = qx{../src/task rc:bug.rc list 2>&1};
like   ($output, qr/zero/, 'list - zero included');
like   ($output, qr/one/,  'list - one included');
like   ($output, qr/two/,  'list - two included');

$output = qx{../src/task rc:bug.rc list pro:a 2>&1};
unlike ($output, qr/zero/, 'list - zero excluded');
like   ($output, qr/one/,  'list - one included');
like   ($output, qr/two/,  'list - two included');

$output = qx{../src/task rc:bug.rc list pro:a.b 2>&1};
unlike ($output, qr/zero/, 'list - zero included');
like   ($output, qr/one/,  'list - one excluded');
unlike ($output, qr/two/,  'list - two included');

$output = qx{../src/task rc:bug.rc list pro.not:a 2>&1};
like   ($output, qr/zero/, 'list - zero included');
unlike ($output, qr/one/,  'list - one excluded');
unlike ($output, qr/two/,  'list - two excluded');

$output = qx{../src/task rc:bug.rc list pro.not:a.b 2>&1};
like   ($output, qr/zero/, 'list - zero included');
unlike ($output, qr/one/,  'list - one excluded');
like   ($output, qr/two/,  'list - two included');

# Cleanup.
unlink qw(pending.data completed.data undo.data backlog.data synch.key bug.rc);
ok (! -r 'pending.data'   &&
    ! -r 'completed.data' &&
    ! -r 'undo.data'      &&
    ! -r 'backlog.data'   &&
    ! -r 'synch.key'      &&
    ! -r 'bug.rc', 'Cleanup');

exit 0;

