#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib ../../lib);

use Test::More tests => 90;
use Encode qw(decode encode);


BEGIN {
    use_ok 'Test::Mojo';
    use_ok 'Mojolicious::Plugin::Human';
    use_ok 'DateTime';
    use_ok 'Mojo::Util', qw(url_escape);
}

{
    package MyApp;
    use Mojo::Base 'Mojolicious';

    sub startup {
        my ($self) = @_;
        $self->plugin('Human');
    }
    1;
}

my $t = Test::Mojo->new('MyApp');
ok $t, 'Test Mojo created';

note 'basic';
{
    $t->app->routes->get("/test/human")->to( cb => sub {
        my ($self) = @_;

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone  => 'local');
        my $dstr = $dt->strftime('%F %T %z');
        my $tstr = $dt->strftime('%F %T');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';
        is $self->str2time( $tstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';
        is $self->strftime('%T', $tstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $tstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO wo TZ';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $tstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO wo TZ';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $tstr ), $dt->strftime('%F'),
            'human_date from ISO wo TZ';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->render(text => 'OK.');
    });

    $t->get_ok("/test/human")-> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'default timezone';
{
    $t->app->routes->get("/test/human/default")->to( cb => sub {
        my ($self) = @_;

        $self->app->plugin('Human', tz => '-0200');

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone  => '-0200');
        my $dstr = $dt->strftime('%F %T +0400');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    $t->get_ok("/test/human/default")-> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'set timezone';
{
    $t->app->routes->get("/test/human/tz")->to( cb => sub {
        my ($self) = @_;

        $self->app->plugin('Human', tz => '-0200');

        my $tz = '-0300';

        my $time = 60 * 60 * 24;
        my $dt = DateTime->from_epoch( epoch => $time, time_zone  => $tz);
        my $dstr = $dt->strftime("%F %T +0100");

        is $self->str2time( $dstr, $tz ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr, $tz), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr, $tz ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time, $tz ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr, $tz ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time, $tz ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr, $tz ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time, $tz ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    $t->get_ok("/test/human/tz")-> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'cookie timezone numeric';
{
    my $tz = '-0300';

    $t->app->routes->get("/test/human/cookie/num")->to( cb => sub {
        my ($self) = @_;

        $self->app->plugin('Human', tz => '-0200');

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone  => $tz);
        my $dstr = $dt->strftime('%F %T +0600');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    my $cookie = Mojo::Cookie::Request->new(name => 'tz', value => $tz);

    $t  -> get_ok("/test/human/cookie/num" => {'Cookie' => $cookie->to_string} )
        -> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'cookie timezone numeric escaped';
{
    my $tz  = '+0300';
    my $esc = url_escape $tz;

    $t->app->routes->get("/test/human/cookie/esc")->to( cb => sub {
        my ($self) = @_;

        $self->app->plugin('Human', tz => '-0200');

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone  => $tz);
        my $dstr = $dt->strftime('%F %T +0600');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    my $cookie = Mojo::Cookie::Request->new(name => 'tz', value => $esc);

    $t  -> get_ok("/test/human/cookie/esc" => {'Cookie' => $cookie->to_string} )
        -> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'cookie timezone alpha';
{
    my $tz = 'America/New_York';

    $t->app->routes->get("/test/human/cookie/alp")->to( cb => sub {
        my ($self) = @_;

        $self->app->plugin('Human', tz => 'Asia/Kolkata');

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone  => $tz);

        my $dstr = $dt->strftime('%F %T +0600');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    my $cookie = Mojo::Cookie::Request->new(name => 'tz', value => $tz);

    $t  -> get_ok("/test/human/cookie/alp" => {'Cookie' => $cookie->to_string} )
        -> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'cookie timezone error';
{
    my $tz = 'SomeStringNotTimeZone!';

    $t->app->routes->get("/test/human/cookie/err")->to( cb => sub {
        my ($self) = @_;

        my $default = 'Asia/Kolkata';
        $self->app->plugin('Human', tz => $default);

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone => $default);
        my $dstr = $dt->strftime('%F %T %z');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    my $cookie = Mojo::Cookie::Request->new(name => 'tz', value => $tz);

    $t  -> get_ok("/test/human/cookie/err" => {'Cookie' => $cookie->to_string} )
        -> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'cookie timezone like something right';
{
    my $tz = 'SomeStringNotTimeZone/SomeStringNotTimeZone';

    $t->app->routes->get("/test/human/cookie/like")->to( cb => sub {
        my ($self) = @_;

        my $default = 'Asia/Kolkata';
        $self->app->plugin('Human', tz => $default);

        my $time = 60 * 60 * 24;
        my $dt   = DateTime->from_epoch( epoch => $time, time_zone => $default);
        my $dstr = $dt->strftime('%F %T %z');

        is $self->str2time( $dstr ), $dt->epoch, 'str2time';

        is $self->strftime('%T', $dstr), $dt->strftime('%T'),   'strftime';

        is $self->human_datetime( $dstr ), $dt->strftime('%F %H:%M'),
            'human_datetime from ISO';
        is $self->human_datetime( $time ), $dt->strftime('%F %H:%M'),
            'human_datetime from timestamp';

        is $self->human_time( $dstr ), $dt->strftime('%H:%M:%S'),
            'human_time from ISO';
        is $self->human_time( $time ), $dt->strftime('%H:%M:%S'),
            'human_time from timestamp';

        is $self->human_date( $dstr ), $dt->strftime('%F'),
            'human_date from ISO';
        is $self->human_date( $time ), $dt->strftime('%F'),
            'human_date from timestamp';

        $self->app->plugin('Human', tz => 'local');

        $self->render(text => 'OK.');
    });

    my $cookie = Mojo::Cookie::Request->new(name => 'tz', value => $tz);

    $t  -> get_ok("/test/human/cookie/like" => {'Cookie' => $cookie->to_string})
        -> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

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

