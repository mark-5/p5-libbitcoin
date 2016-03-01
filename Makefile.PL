use strict;
use warnings;
use inc::Module::Install;
use Config;
use ExtUtils::CppGuess;
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use IO::Select;
use IPC::Open3 qw(open3);
use Symbol qw(gensym);


assert_lib(inc => 'bitcoin/bitcoin.hpp', lib => 'bitcoin');

use_ppport;
cc_include_paths 'include';
cc_libs '-lbitcoin';
cc_src_paths 'src';
makemaker_args cpp_makemaker_args(), XSOPT => '-hiertype';


extra_tests;
license 'perl';
perl_version '5.008';
readme_pod_from 'lib/Libbitcoin.pm';
all_from 'lib/Libbitcoin.pm';

homepage   'https://github.com/mark-5/p5-libbitcoin';
bugtracker 'https://github.com/mark-5/p5-libbitcoin/issues';
repository 'https://github.com/mark-5/p5-libbitcoin.git';


WriteAll;


sub assert_lib {
    my %args = (
        cc       => cpp_compiler(),
        function => 'int main(void) { return 0; }',
        @_,
    );
    $args{headers} ||= [($args{header})x!! $args{header}];
    $args{verify}  ||= sub { die $_->{stderr} if $_->{exit} };

    my $source = '';
    $source   .= "#include <$_>\n" for @{$args{headers}};
    $source   .= $args{function};

    my $dir = tempdir(CLEANUP => 1);
    my $cpp = catfile($dir, "assertlib.cpp");
    my $o   = catfile($dir, "assertlib.o");
    write_file($cpp, $source);

    my $cmd = $args{cc};
    $cmd   .= " $args{ccflags}" if $args{ccflags};
    $cmd   .= " -I$args{inc}"   if $args{inc};
    $cmd   .= " -l$args{lib}"   if $args{lib};
    $cmd   .= " -o $o";
    $cmd   .= " $cpp";

    local $_ = run_cmd($cmd);
    $args{verify}->($_);
}

sub check_lib {
    my (%args) = @_;
    return eval { assert_lib(%args); 1 };
}

sub cpp_compiler {
    our $_cpp_compiler;
    $_cpp_compiler ||= do {
        my $guess = ExtUtils::CppGuess->new->guess_compiler;
        sprintf join " ", $Config{cc}, @{$guess}{qw(extra_cflags extra_lflags)};
    };
}

sub write_file {
    my ($path, $data) = @_;
    open my($fh), '>', $path or die "Can't open $path for writing: $!";
    print $fh $data;
    close $fh;
}

sub run_cmd {
    my ($cmd) = @_;

    my ($stdin, $stdout);
    my $stderr  = gensym();
    my $pid     = open3($stdin, $stdout, $stderr, $cmd) or die "Couldn't run $cmd: $!";
    my $results = {command => $cmd, stdout => '', stderr => ''};

    my $s = IO::Select->new($stdout, $stderr);
    while (my @ready = $s->can_read) {
        for my $fh (@ready) {
            my $type  = $fh eq $stdout ? 'stdout' : 'stderr';
            my $bytes = sysread($fh, my($buf), 2048);
            if ($bytes) {
                $results->{$type} .= $buf;
            } elsif (defined $bytes) {
                $s->remove($fh);
            } else {
                die "Couldn't read $type from $cmd: $!";
            }
        }
    }
    waitpid($pid, 0);
    $results->{exit} = $? >> 8;

    return $results;
}

sub cpp_makemaker_args {
    my %args = ExtUtils::CppGuess->new->makemaker_options;
    $args{CCFLAGS} .= ' ' . cpp_std_flag();
    return %args;
}

sub cpp_std_flag {
    my @standards = qw(-std=c++11 -std=c++0x);
    for my $flag (@standards) {
        return $flag if check_lib(ccflags => $flag);
    }

    warn "Couldn't guess language standard flag that works with " . cpp_compiler() . ".\n";
    warn "Tried @standards.\n";
    exit 0;
};
