package Test::Function;
use strict;
use warnings;
our $VERSION = '0.01';

sub import {
    my $caller = caller(0);

    no strict 'refs';
    *{"${caller}::MODIFY_CODE_ATTRIBUTES"} = \&_MODIFY_CODE_ATTRIBUTES;
}

sub _fake {
    my ($pkg, $code) = @_;

    my $fake = sub {
        local $Test::Builder::Level = $Test::Builder::Level + 2;
        $code->(@_);
    };

    require B;
    my $funcname = B::svref_2object($code)->GV->NAME;

    no strict 'refs';
    *{"${pkg}::${funcname}"} = $fake;
}

sub _MODIFY_CODE_ATTRIBUTES {
    my ($pkg, $code, @attrs) = @_;
    return unless $attrs[0] =~ /^Test$/;
    _fake($pkg, $code);
    return;
}

1;

__END__

=head1 NAME

Test::Function - auto set $Test::Builder::Level

=head1 SYNOPSIS

  use Test::More;
  use Test::Function;
  
  sub test_foo : Test {
      ok 0;
  }
  test_foo(); # test failed. report line at call test_foo().

=head1 DESCRIPTION

Test::Function is auto set $Test::Builder::Level.

=head1 AUTHOR

Atsushi Kobayashi E<lt>nekokak _at_ gmail _dot_ comE<gt>

=head1 CONTRIBUTORS

kamipo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
