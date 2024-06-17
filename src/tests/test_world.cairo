#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import test utils
    use stark_farmland::models::{
        player::{Player, player}, tree::{Tree, TreeStage, TreeManager, TREE_MANAGER, tree},
        land::{Land, LandManager, LAND_MANAGER, land}
    };
    use stark_farmland::systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}};

    #[test]
    fn test_plant() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![
            player::TEST_CLASS_HASH, tree::TEST_CLASS_HASH, land::TEST_CLASS_HASH
        ];

        // deploy world with models
        let world = spawn_test_world(models);

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // call spawn
        actions_system.spawn();

        let land_mananger = get!(world, LAND_MANAGER, (LandManager));
        assert(land_mananger.current_land_id == 1, 'current_land_id err');

        // call plant 0
        actions_system.plant(1);

        // Check world state
        let player = get!(world, caller, (Player));

        let mut player_land_array = player.land_array;
        let mut player_tree_array = player.tree_array;

        assert(player.is_spawn, 'spawn err');
        assert(*player_land_array.at(0) == 1, 'land array err');
        assert(*player_tree_array.at(0) == 1, 'land array err');
        assert(player.seed_amount == 0, 'seed amount err');
    // watering myself
    // actions_system.watering_myself(0);
    }
}
