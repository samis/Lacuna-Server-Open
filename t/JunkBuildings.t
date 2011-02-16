use lib '../lib';
use Test::More tests => 15;
use Test::Deep;
use Data::Dumper;
use 5.010;

use TestHelper;
my $tester = TestHelper->new->generate_test_empire->build_infrastructure;
my $session_id = $tester->session->id;
diag("session id: $session_id");
my $home_planet = $tester->empire->home_planet_id;
diag("home_planet: $home_planet");
my $empire_id = $tester->empire->id;

my $db = Lacuna->db;
my $empire = $db->resultset('Lacuna::DB::Result::Empire')->find($empire_id);
my $home = $empire->home_planet;

#$db->resultset('Lacuna::DB::Result::Building')->search({class=>'Lacuna::DB::Result::Building::Permanent::JunkHengeSculpture'})->delete;
#$db->resultset('Lacuna::DB::Result::Building')->search({class=>'Lacuna::DB::Result::Building::Permanent::GreatBallOfJunk'})->delete;
#$db->resultset('Lacuna::DB::Result::Building')->search({class=>'Lacuna::DB::Result::Building::Permanent::MetalJunkArches'})->delete;
#$db->resultset('Lacuna::DB::Result::Building')->search({class=>'Lacuna::DB::Result::Building::Permanent::SpaceJunkPark'})->delete;
#$db->resultset('Lacuna::DB::Result::Building')->search({class=>'Lacuna::DB::Result::Building::Permanent::PyramidJunkSculpture'})->delete;

my $construction_cost_reduction_bonus = (100 - $empire->research_affinity * 5) / 100;
diag("construction_cost_reduction_bonus is ", $construction_cost_reduction_bonus);

my @builds = (
	{ type => 'junkhengesculpture', name => 'Junk Henge Sculpture', x => 4, y => 1, },
	{ type => 'greatballofjunk', name => 'Great Ball of Junk', x => 4, y => 2, },
	{ type => 'metaljunkarches', name => 'Metal Junk Arches', x => 4, y => 3, },
	{ type => 'spacejunkpark', name => 'Space Junk Park', x => 4, y => 4, },
	{ type => 'pyramidjunksculpture', name => 'Pyramid Junk Sculpture', x => 4, y => 5, },
);

for my $build ( @builds ) {
	my $result = $tester->post($build->{type}, 'build', [$session_id, $home_planet, $build->{x}, $build->{y}]);
	is($result->{error}{code}, 1011, "Not enough waste in storage to build this.");

	$result = $tester->post('body', 'get_status', [$session_id, $home_planet]);
	my $starting_waste = $result->{result}{body}{waste_stored};

	$result = $tester->post('body', 'get_buildable', [$session_id, $home_planet, $build->{x}, $build->{y}, 'Waste']);
	my $cost_to_build = $result->{result}{buildable}{$build->{name}}{build}{cost}{waste};
	my $orig_cost = $cost_to_build / $construction_cost_reduction_bonus;

	my $amount = 0 - $cost_to_build;
	$home->waste_capacity($amount);
	$home->waste_stored($amount);
	$home->update;

	$result = $tester->post('body', 'get_status', [$session_id, $home_planet]);
	my $last_waste = $result->{result}{body}{waste_stored};

	$result = $tester->post($build->{type}, 'build', [$session_id, $home_planet, $build->{x} + 1, $build->{y}]);
	$build->{building} = $db->resultset('Lacuna::DB::Result::Building')->find($result->{result}{building}{id});
	$build->{building}->finish_upgrade;

	$result = $tester->post('body', 'get_status', [$session_id, $home_planet]);
	my $final_waste = $result->{result}{body}{waste_stored};
	cmp_ok($last_waste, '>', $final_waste, 'Waste is being spent.');

	is($final_waste, 0, "No waste left");
}

END {
	for my $build ( @builds ) {
		$build->{building}->delete;
	}
    $tester->cleanup;
}

