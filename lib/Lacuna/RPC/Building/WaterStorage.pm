package Lacuna::RPC::Building::WaterStorage;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::RPC::Building';

sub app_url {
    return '/waterstorage';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::Water::Storage';
}

sub dump {
    my ($self, $session_id, $building_id,  $amount) = @_;
	if ($amount <= 0) {
		confess [1009, 'You must specify an amount greater than 0.'];
	}
    my $empire = $self->get_empire_by_session($session_id);
    my $building = $self->get_building($empire, $building_id);
    my $body = $building->body;
    $body->spend_type('water', $amount);
    $body->add_type('waste', $amount);
    $body->update;
    return {
        status      => $self->format_status($empire, $body),
        };
}

__PACKAGE__->register_rpc_method_names(qw(dump));

no Moose;
__PACKAGE__->meta->make_immutable;

