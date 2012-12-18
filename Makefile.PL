use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => "Mojolicious::Plugin::Human",
    VERSION_FROM    => "lib/Mojolicious/Plugin/Human.pm",
    ABSTRACT_FROM   => "lib/Mojolicious/Plugin/Human.pm",
    MAKEFILE        => 'Makefile',
    LICENSE         => 'Perl',
    AUTHOR          => [
        'Dmitry E. Oboukhov <unera@debian.org>,',
        'Roman V. Nikolaev <rshadow@rambler.ru>',
    ],
    PREREQ_PM       => {
        'Mojo::Base'                    => 0,
        'DateTime'                      => 0,
        'DateTime::Format::DateParse'   => 0,
    }
);
