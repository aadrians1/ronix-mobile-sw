package Config;
use Exporter ();
@ISA = (Exporter);
@EXPORT = qw(%Config);
@EXPORT_OK = qw(myconfig config_sh config_vars);

$] == 5.002
  or die "Perl lib version (5.002) doesn't match executable version ($])\n";

# This file was created by configpm when Perl was built. Any changes
# made to this file will be lost the next time perl is built.

##
## This file was produced by running the Configure script. It holds all the
## definitions figured out by Configure. Should you modify one of these values,
## do not forget to propagate your changes by running "Configure -der". You may
## instead choose to run each of the .SH files by yourself, or "Configure -S".
##
#
## Configuration time: Fri Mar 15 21:06:09 PST 1996
## Configured by: root
## Target system: sunos beastie 5.5 generic sun4m sparc sunw,sparcstation-20 
#

my $config_sh = <<'!END!';
archlibexp='/usr/local/lib/perl5/sun4-solaris/5.002'
archname='sun4-solaris'
cc='gcc'
ccflags='-I/usr/local/include'
cppflags='-I/usr/local/include'
dlsrc='dl_dlopen.xs'
dynamic_ext='Fcntl FileHandle GDBM_File NDBM_File ODBM_File POSIX SDBM_File Safe Socket'
extensions='Fcntl FileHandle GDBM_File NDBM_File ODBM_File POSIX SDBM_File Safe Socket'
installarchlib='/usr/local/lib/perl5/sun4-solaris/5.002'
installprivlib='/usr/local/lib/perl5'
libpth='/usr/local/lib /lib /usr/lib /usr/ccs/lib'
libs='-lsocket -lnsl -lgdbm -ldb -ldl -lm -lc -lcrypt'
osname='solaris'
osvers='2.4'
prefix='/usr/local'
privlibexp='/usr/local/lib/perl5'
sharpbang='#!'
shsharp='true'
sig_name='ZERO HUP INT QUIT ILL TRAP ABRT EMT FPE KILL BUS SEGV SYS PIPE ALRM TERM USR1 USR2 CHLD PWR WINCH URG IO STOP TSTP CONT TTIN TTOU VTALRM PROF XCPU XFSZ WAITING LWP FREEZE THAW CANCEL RTMIN NUM38 NUM39 NUM40 NUM41 NUM42 NUM43 RTMAX IOT CLD POLL '
so='so'
startsh='#!/bin/sh'
static_ext=' '
Author=''
CONFIG='true'
Date='$Date'
Header=''
Id='$Id'
Locker=''
Log='$Log'
Mcc='Mcc'
PATCHLEVEL='2'
RCSfile='$RCSfile'
Revision='$Revision'
SUBVERSION='0'
Source=''
State=''
afs='false'
alignbytes='8'
aphostname=''
ar='ar'
archlib='/usr/local/lib/perl5/sun4-solaris/5.002'
archobjs=''
awk='awk'
baserev='5.0'
bash=''
bin='/usr/local/bin'
binexp='/usr/local/bin'
bison=''
byacc='byacc'
byteorder='4321'
c='\c'
castflags='0'
cat='cat'
cccdlflags='-fpic'
ccdlflags=' '
cf_by='root'
cf_email='root@beastie.atext.com'
cf_time='Fri Mar 15 21:06:09 PST 1996'
chgrp=''
chmod=''
chown=''
clocktype='clock_t'
comm='comm'
compress=''
contains='grep'
cp='cp'
cpio=''
cpp='cpp'
cpp_stuff='42'
cpplast='-'
cppminus='-'
cpprun='gcc -E'
cppstdin='gcc -E'
cryptlib=''
csh='csh'
d_Gconvert='gconvert((x),(n),(t),(b))'
d_access='define'
d_alarm='define'
d_archlib='define'
d_attribut='define'
d_bcmp='undef'
d_bcopy='undef'
d_bsd='define'
d_bsdpgrp='undef'
d_bzero='define'
d_casti32='define'
d_castneg='define'
d_charvspr='undef'
d_chown='define'
d_chroot='define'
d_chsize='undef'
d_closedir='define'
d_const='define'
d_crypt='define'
d_csh='define'
d_cuserid='define'
d_dbl_dig='define'
d_difftime='define'
d_dirnamlen='undef'
d_dlerror='define'
d_dlopen='define'
d_dlsymun='undef'
d_dosuid='undef'
d_dup2='define'
d_eofnblk='define'
d_eunice='undef'
d_fchmod='define'
d_fchown='define'
d_fcntl='define'
d_fd_macros='define'
d_fd_set='define'
d_fds_bits='define'
d_fgetpos='define'
d_flexfnam='define'
d_flock='undef'
d_fork='define'
d_fpathconf='define'
d_fsetpos='define'
d_getgrps='define'
d_gethent='define'
d_gethname='undef'
d_getlogin='define'
d_getpgrp2='undef'
d_getpgrp='define'
d_getppid='define'
d_getprior='define'
d_htonl='define'
d_index='undef'
d_isascii='define'
d_killpg='define'
d_link='define'
d_locconv='define'
d_lockf='define'
d_lstat='define'
d_mblen='define'
d_mbstowcs='define'
d_mbtowc='define'
d_memcmp='define'
d_memcpy='define'
d_memmove='define'
d_memset='define'
d_mkdir='define'
d_mkfifo='define'
d_mktime='define'
d_msg='define'
d_msgctl='define'
d_msgget='define'
d_msgrcv='define'
d_msgsnd='define'
d_mymalloc='define'
d_nice='define'
d_oldarchlib='define'
d_oldsock='undef'
d_open3='define'
d_pathconf='define'
d_pause='define'
d_phostname='undef'
d_pipe='define'
d_poll='define'
d_portable='define'
d_pwage='define'
d_pwchange='undef'
d_pwclass='undef'
d_pwcomment='define'
d_pwexpire='undef'
d_pwquota='undef'
d_readdir='define'
d_readlink='define'
d_rename='define'
d_rewinddir='define'
d_rmdir='define'
d_safebcpy='undef'
d_safemcpy='undef'
d_seekdir='define'
d_select='define'
d_sem='define'
d_semctl='define'
d_semget='define'
d_semop='define'
d_setegid='define'
d_seteuid='define'
d_setlinebuf='define'
d_setlocale='define'
d_setpgid='define'
d_setpgrp2='undef'
d_setpgrp='define'
d_setprior='define'
d_setregid='define'
d_setresgid='undef'
d_setresuid='undef'
d_setreuid='define'
d_setrgid='undef'
d_setruid='undef'
d_setsid='define'
d_shm='define'
d_shmat='define'
d_shmatprototype='define'
d_shmctl='define'
d_shmdt='define'
d_shmget='define'
d_shrplib='undef'
d_sigaction='define'
d_sigintrp=''
d_sigsetjmp='define'
d_sigvec='undef'
d_sigvectr='undef'
d_socket='define'
d_sockpair='define'
d_statblks='define'
d_stdio_cnt_lval='define'
d_stdio_ptr_lval='define'
d_stdiobase='define'
d_stdstdio='define'
d_strchr='define'
d_strcoll='define'
d_strctcpy='define'
d_strerrm='strerror(e)'
d_strerror='define'
d_strxfrm='define'
d_suidsafe='define'
d_symlink='define'
d_syscall='define'
d_sysconf='define'
d_sysernlst=''
d_syserrlst='define'
d_system='define'
d_tcgetpgrp='define'
d_tcsetpgrp='define'
d_telldir='define'
d_time='define'
d_times='define'
d_truncate='define'
d_tzname='define'
d_umask='define'
d_uname='define'
d_vfork='undef'
d_void_closedir='undef'
d_voidsig='define'
d_voidtty=''
d_volatile='define'
d_vprintf='define'
d_wait4='define'
d_waitpid='define'
d_wcstombs='define'
d_wctomb='define'
d_xenix='undef'
date='date'
db_hashtype='int'
db_prefixtype='int'
defvoidused='15'
direntrytype='struct dirent'
dlext='so'
eagain='EAGAIN'
echo='echo'
egrep='egrep'
emacs=''
eunicefix=':'
exe_ext=''
expr='expr'
find='find'
firstmakefile='makefile'
flex=''
fpostype='fpos_t'
freetype='void'
full_csh='/usr/bin/csh'
full_sed='/usr/bin/sed'
gcc=''
gccversion='2.7.2'
gidtype='gid_t'
glibpth='/usr/shlib /lib/pa1.1 /usr/lib/large /lib /usr/lib /usr/lib/386 /lib/386 /lib/large /usr/lib/small /lib/small /usr/ccs/lib /usr/shlib'
grep='grep'
groupcat=''
groupstype='gid_t'
h_fcntl='true'
h_sysfile='false'
hint='recommended'
hostcat=''
huge=''
i_bsdioctl=''
i_db='undef'
i_dbm='undef'
i_dirent='define'
i_dld='undef'
i_dlfcn='define'
i_fcntl='define'
i_float='define'
i_gdbm='define'
i_grp='define'
i_limits='define'
i_locale='define'
i_malloc='define'
i_math='define'
i_memory='undef'
i_ndbm='define'
i_neterrno='undef'
i_niin='define'
i_pwd='define'
i_rpcsvcdbm='define'
i_sgtty='undef'
i_stdarg='define'
i_stddef='define'
i_stdlib='define'
i_string='define'
i_sysdir='undef'
i_sysfile='undef'
i_sysfilio='define'
i_sysin='undef'
i_sysioctl='define'
i_sysndir='undef'
i_sysparam='define'
i_sysselct='define'
i_syssockio=''
i_sysstat='define'
i_systime='define'
i_systimek='undef'
i_systimes='define'
i_systypes='define'
i_sysun='define'
i_termio='undef'
i_termios='define'
i_time='undef'
i_unistd='define'
i_utime='define'
i_varargs='undef'
i_varhdr='stdarg.h'
i_vfork='undef'
incpath=''
inews=''
installbin='/usr/local/bin'
installman1dir='/usr/local/man/man1'
installman3dir='/usr/local/lib/perl5/man/man3'
installscript='/usr/local/bin'
installsitearch='/usr/local/lib/perl5/site_perl/sun4-solaris'
installsitelib='/usr/local/lib/perl5/site_perl'
intsize='4'
known_extensions='DB_File Fcntl FileHandle GDBM_File NDBM_File ODBM_File POSIX SDBM_File Safe Socket'
ksh=''
large=''
ld='gcc'
lddlflags='-G -L/usr/local/lib'
ldflags=' -L/usr/local/lib'
less='less'
lib_ext='.a'
libc='/lib/libc.so'
libswanted='net socket inet nsl nm ndbm gdbm dbm db dl dld sun m c cposix posix ndir dir crypt bsd BSD PW x'
line='line'
lint=''
lkflags=''
ln='ln'
lns='/usr/bin/ln -s'
locincpth='/usr/local/include /opt/local/include /usr/gnu/include /opt/gnu/include /usr/GNU/include /opt/GNU/include'
loclibpth='/usr/local/lib /opt/local/lib /usr/gnu/lib /opt/gnu/lib /usr/GNU/lib /opt/GNU/lib'
lp=''
lpr=''
ls='ls'
lseektype='off_t'
mail=''
mailx=''
make=''
mallocobj='malloc.o'
mallocsrc='malloc.c'
malloctype='void *'
man1dir='/usr/local/man/man1'
man1direxp='/usr/local/man/man1'
man1ext='1'
man3dir='/usr/local/lib/perl5/man/man3'
man3direxp='/usr/local/lib/perl5/man/man3'
man3ext='3'
medium=''
mips=''
mips_type=''
mkdir='mkdir'
models='none'
modetype='mode_t'
more='more'
mv=''
myarchname='sun4-solaris'
mydomain='.atext.com'
myhostname='beastie'
myuname='sunos beastie 5.5 generic sun4m sparc sunw,sparcstation-20 '
n=''
nm_opt='-p'
nm_so_opt=''
nroff='nroff'
o_nonblock='O_NONBLOCK'
obj_ext='.o'
oldarchlib='/usr/local/lib/perl5/sun4-solaris'
oldarchlibexp='/usr/local/lib/perl5/sun4-solaris'
optimize='-O'
orderlib='false'
package='perl5'
pager='/usr/bin/more'
passcat=''
patchlevel='2'
path_sep=':'
perl='perl'
perladmin='root@beastie.atext.com'
perlpath='/usr/local/bin/perl'
pg='pg'
phostname='hostname'
plibpth=''
pmake=''
pr=''
prefixexp='/usr/local'
privlib='/usr/local/lib/perl5'
prototype='define'
randbits='15'
ranlib=':'
rd_nodata='-1'
rm='rm'
rmail=''
runnm='true'
scriptdir='/usr/local/bin'
scriptdirexp='/usr/local/bin'
sed='sed'
selecttype='fd_set *'
sendmail='sendmail'
sh=''
shar=''
shmattype='void *'
shrpdir='none'
sig_num='0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 6 18 22 '
signal_t='void'
sitearch='/usr/local/lib/perl5/site_perl/sun4-solaris'
sitearchexp='/usr/local/lib/perl5/site_perl/sun4-solaris'
sitelib='/usr/local/lib/perl5/site_perl'
sitelibexp='/usr/local/lib/perl5/site_perl'
sizetype='size_t'
sleep=''
smail=''
small=''
sockethdr=''
socketlib=''
sort='sort'
spackage='Perl5'
spitshell='cat'
split=''
ssizetype='ssize_t'
startperl='#!/usr/local/bin/perl'
stdchar='unsigned char'
stdio_base='((fp)->_base)'
stdio_bufsiz='((fp)->_cnt + (fp)->_ptr - (fp)->_base)'
stdio_cnt='((fp)->_cnt)'
stdio_ptr='((fp)->_ptr)'
strings='/usr/include/string.h'
submit=''
sysman='/usr/man/man1'
tail=''
tar=''
tbl=''
test='test'
timeincl='/usr/include/sys/time.h '
timetype='time_t'
touch='touch'
tr='tr'
troff=''
uidtype='uid_t'
uname='uname'
uniq='uniq'
usedl='define'
usemymalloc='y'
usenm='true'
useposix='true'
usesafe='true'
usevfork='false'
usrinc='/usr/include'
uuname=''
vi=''
voidflags='15'
xlibpth='/usr/lib/386 /lib/386'
zcat=''
!END!

my $summary = <<'!END!';
Summary of my $package ($baserev patchlevel $PATCHLEVEL) configuration:
  Platform:
    osname=$osname, osver=$osvers, archname=$archname
    uname='$myuname'
    hint=$hint, useposix=$useposix 
  Compiler:
    cc='$cc', optimize='$optimize', gccversion=$gccversion
    cppflags='$cppflags'
    ccflags ='$ccflags'
    stdchar='$stdchar', d_stdstdio=$d_stdstdio, usevfork=$usevfork
    voidflags=$voidflags, castflags=$castflags, d_casti32=$d_casti32, d_castneg=$d_castneg
    intsize=$intsize, alignbytes=$alignbytes, usemymalloc=$usemymalloc, randbits=$randbits
  Linker and Libraries:
    ld='$ld', ldflags ='$ldflags'
    libpth=$libpth
    libs=$libs
    libc=$libc, so=$so
  Dynamic Linking:
    dlsrc=$dlsrc, dlext=$dlext, d_dlsymun=$d_dlsymun, ccdlflags='$ccdlflags'
    cccdlflags='$cccdlflags', lddlflags='$lddlflags'

!END!
my $summary_expanded = 0;

sub myconfig {
	return $summary if $summary_expanded;
	$summary =~ s/\$(\w+)/$Config{$1}/ge;
	$summary_expanded = 1;
	$summary;
}

tie %Config, Config;
sub TIEHASH { bless {} }
sub FETCH { 
    # check for cached value (which maybe undef so we use exists not defined)
    return $_[0]->{$_[1]} if (exists $_[0]->{$_[1]});
 
    my($value); # search for the item in the big $config_sh string
    return undef unless (($value) = $config_sh =~ m/^$_[1]='(.*)'\s*$/m);
 
    $value = undef if $value eq 'undef'; # So we can say "if $Config{'foo'}".
    $_[0]->{$_[1]} = $value; # cache it
    return $value;
}
 
my $prevpos = 0;

sub FIRSTKEY {
    $prevpos = 0;
    my($key) = $config_sh =~ m/^(.*?)=/;
    $key;
}

sub NEXTKEY {
    my $pos = index($config_sh, "\n", $prevpos) + 1;
    my $len = index($config_sh, "=", $pos) - $pos;
    $prevpos = $pos;
    $len > 0 ? substr($config_sh, $pos, $len) : undef;
}

sub EXISTS { 
     exists($_[0]->{$_[1]})  or  $config_sh =~ m/^$_[1]=/m; 
}

sub STORE  { die "\%Config::Config is read-only\n" }
sub DELETE { &STORE }
sub CLEAR  { &STORE }


sub config_sh {
    $config_sh
}
sub config_vars {
    foreach(@_){
	my $v=(exists $Config{$_}) ? $Config{$_} : 'UNKNOWN';
	$v='undef' unless defined $v;
	print "$_='$v';\n";
    }
}

1;
__END__

=head1 NAME

Config - access Perl configuration information

=head1 SYNOPSIS

    use Config;
    if ($Config{'cc'} =~ /gcc/) {
	print "built by gcc\n";
    } 

    use Config qw(myconfig config_sh config_vars);

    print myconfig();

    print config_sh();

    config_vars(qw(osname archname));


=head1 DESCRIPTION

The Config module contains all the information that was available to
the C<Configure> program at Perl build time (over 900 values).

Shell variables from the F<config.sh> file (written by Configure) are
stored in the readonly-variable C<%Config>, indexed by their names.

Values stored in config.sh as 'undef' are returned as undefined
values.  The perl C<exists> function can be used to check is a
named variable exists.

=over 4

=item myconfig()

Returns a textual summary of the major perl configuration values.
See also C<-V> in L<perlrun/Switches>.

=item config_sh()

Returns the entire perl configuration information in the form of the
original config.sh shell variable assignment script.

=item config_vars(@names)

Prints to STDOUT the values of the named configuration variable. Each is
printed on a separate line in the form:

  name='value';

Names which are unknown are output as C<name='UNKNOWN';>.
See also C<-V:name> in L<perlrun/Switches>.

=back

=head1 EXAMPLE

Here's a more sophisticated example of using %Config:

    use Config;

    defined $Config{sig_name} || die "No sigs?";
    foreach $name (split(' ', $Config{sig_name})) {
	$signo{$name} = $i;
	$signame[$i] = $name;
	$i++;
    }   

    print "signal #17 = $signame[17]\n";
    if ($signo{ALRM}) { 
	print "SIGALRM is $signo{ALRM}\n";
    }   

=head1 WARNING

Because this information is not stored within the perl executable
itself it is possible (but unlikely) that the information does not
relate to the actual perl binary which is being used to access it.

The Config module is installed into the architecture and version
specific library directory ($Config{installarchlib}) and it checks the
perl version number when loaded.

=head1 NOTE

This module contains a good example of how to use tie to implement a
cache and an example of how to make a tied variable readonly to those
outside of it.

=cut

