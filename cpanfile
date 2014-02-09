requires 'perl', '5.008005';
requires 'JSON', '2.00';
requires 'LWP::Protocol::https';

on test => sub {
    requires 'Test::More', '0.88';
};
