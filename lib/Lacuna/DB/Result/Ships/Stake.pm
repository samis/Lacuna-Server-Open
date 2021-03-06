package Lacuna::DB::Result::Ships::Stake;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result::Ships';

use constant prereq                 => [ { class=> 'Lacuna::DB::Result::Building::Observatory',  level => 10 } ];
use constant base_food_cost         => 3000;
use constant base_water_cost        => 4000;
use constant base_energy_cost       => 10000;
use constant base_ore_cost          => 10000;
use constant base_time_cost         => 60 * 60 * 2;
use constant base_waste_cost        => 3500;
use constant base_speed             => 3000;
use constant base_combat            => 250;
use constant base_stealth           => 0;
use constant base_hold_size         => 0;
use constant pilotable              => 0;
use constant build_tags             => ['Colonization'];

with "Lacuna::Role::Ship::Send::Planet";
with "Lacuna::Role::Ship::Send::Uninhabited";
with "Lacuna::Role::Ship::Send::IsHostile";
with "Lacuna::Role::Ship::Arrive::TriggerDefense";
with "Lacuna::Role::Ship::Arrive::StakeAClaim";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
