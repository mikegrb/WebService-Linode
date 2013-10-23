requires 'perl', '5.008005';
requires 'JSON', '2.00';
requires 'LWP::UserAgent';
requires 'Crypt::SSLeay';
requires 'Mozilla::CA';

on test => sub {
    requires 'Test::More', '0.88';
};
