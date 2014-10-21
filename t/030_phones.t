#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib ../../lib);

use Test::More tests => 13;
use Encode qw(decode encode);


BEGIN {
    use_ok 'Test::Mojo';
    use_ok 'Mojolicious::Plugin::Human';
    use_ok 'DateTime';
}

{
    package MyApp;
    use Mojo::Base 'Mojolicious';

    sub startup {
        my ($self) = @_;
        $self->plugin('Human', phone_add => ',');
    }
    1;
}

my $t = Test::Mojo->new('MyApp');
ok $t, 'Test Mojo created';

$t->app->routes->get("/test/human")->to( cb => sub {
    my ($self) = @_;

    is $self->human_phones('1234567890'), '+7-123-456-7890',
        'human_phones';
    is $self->human_phones('1234567890,0987654321'),
        '+7-123-456-7890, +7-098-765-4321',
        'human_phones many';
    is $self->flat_phone('1234567890'), '+71234567890', 'flat_phone';
    is $self->human_phones('+79856395409'), '+7-985-639-5409',
        'human_phones - example 1';

    is $self->human_phones('1234567890w12345'), '+7-123-456-7890,12345',
        'human_phones with additional';
    is $self->human_phones('+71234567890w12345'), '+7-123-456-7890,12345',
        'human_phones with additional and country';
    is $self->human_phones('+74953696027w00171'), '+7-495-369-6027,00171',
        'human_phones with additional and country - example 1';

    $self->render(text => 'OK.');
});

$t->get_ok("/test/human")-> status_is( 200 );

diag decode utf8 => $t->tx->res->body unless $t->tx->success;

=head1 AUTHORS

Dmitry E. Oboukhov <unera@debian.org>,
Roman V. Nikolaev <rshadow@rambler.ru>

=head1 COPYRIGHT

Copyright (C) 2011 Dmitry E. Oboukhov <unera@debian.org>
Copyright (C) 2011 Roman V. Nikolaev <rshadow@rambler.ru>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

