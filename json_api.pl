#!/usr/bin/env perl

use Mojolicious::Lite;
use File::Slurp;

# File to store data.
my $data_file = "data.txt";

# Ensure the file exists.
write_file($data_file, '') unless -e $data_file;

# /add route: Adds a name to the file
post '/add' => sub {
    my $c = shift;
    my $name = $c->param('name');

    unless ($name) {
        return $c->render(json => { error => 'Parameter "name" is required' }, status => 400);
    }

    # Append the name to the file.
    append_file($data_file, "$name\n");

    $c->render(json => { success => 1, message => "Name '$name' added" });
};

# /delete route: Removes a name from the file.
post '/delete' => sub {
    my $c = shift;
    my $name = $c->param('name');

    unless ($name) {
        return $c->render(json => { error => 'Parameter "name" is required' }, status => 400);
    }

    # Read the file and filter out the name.
    my @lines = grep { chomp; $_ ne $name } read_file($data_file);

    # Write back the filtered data.
    write_file($data_file, map { "$_\n" } @lines);

    $c->render(json => { success => 1, message => "Name '$name' deleted (if it existed)" });
};

# /list route: Lists all names in the file.
get '/list' => sub {
    my $c = shift;

    # Read all names from the file.
    my @names = read_file($data_file, chomp => 1);

    $c->render(json => { names => \@names });
};

# Start the app.
app->start;

