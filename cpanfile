
on $_ => sub {
    requires 'Devel::CheckLib';
    requires 'ExtUtils::CppGuess';
    requires 'ExtUtils::ParseXS', '3.18';
    requires 'ExtUtils::Typemaps::STL';
} for qw(configure develop);

on develop => sub {
    requires 'Module::Install::CPANfile';
    requires 'Module::Install::ExtraTests';
    requires 'Module::Install::ReadmePodFromPod';
    requires 'Module::Install::XSUtil';
};

on test => sub {
    requires 'Test::Pod', '1.00';
    requires 'Test::Strict';
};
