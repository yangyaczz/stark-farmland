#[dojo::interface]
trait IActions {
    fn spawn(ref world: IWorldDispatcher);

    fn plant(ref world: IWorldDispatcher, land_id: u128);

    fn watering_myself(ref world: IWorldDispatcher, tree_id: u128);
}


// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use stark_farmland::models::{
        player::{Player}, tree::{Tree, TreeStage, TreeManager, TREE_MANAGER},
        land::{Land, LandManager, LAND_MANAGER}
    };


    #[abi(embed_v0)]
    impl PlantActions of IActions<ContractState> {
        fn spawn(ref world: IWorldDispatcher) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));

            let mut land_manager = get!(world, LAND_MANAGER, (LandManager));

            let land_id = land_manager.current_land_id;

            assert(!player.is_spawn, 'already spawn');

            if (!player.is_spawn) {
                set!(
                    world,
                    (
                        Player {
                            player: caller,
                            is_spawn: true,
                            tree_array: array![],
                            land_array: array![land_id],
                            seed_amount: 1
                        },
                        LandManager { key_name: LAND_MANAGER, current_land_id: land_id + 1, },
                        Land { id: land_id, player: caller, is_available: true, }
                    )
                );
            }
        }

        fn plant(ref world: IWorldDispatcher, land_id: u128) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));
            let mut land = get!(world, land_id, (Land));

            let mut tree_manager = get!(world, TREE_MANAGER, (TreeManager));

            assert(land.player == caller && land.is_available, 'land invaild');
            assert(player.seed_amount > 0, 'seed invaild');

            let tree_id: u128 = tree_manager.current_tree_id;

            let mut new_tree_array = player.tree_array;
            new_tree_array.append(tree_id);

            set!(
                world,
                (
                    Tree {
                        id: tree_id,
                        player: caller,
                        water_value: 0,
                        last_watered_timestamp: get_block_timestamp(),
                        is_fruited: false,
                    },
                    TreeManager { key_name: TREE_MANAGER, current_tree_id: tree_id + 1, },
                    Land { id: land.id, player: land.player, is_available: false, },
                    Player {
                        player: player.player,
                        is_spawn: true,
                        tree_array: new_tree_array,
                        land_array: player.land_array,
                        seed_amount: player.seed_amount - 1,
                    }
                )
            )
        }

        fn watering_myself(ref world: IWorldDispatcher, tree_id: u128) {
            let caller = get_caller_address();
            let mut tree = get!(world, tree_id, (Tree));

            // check assert
            assert(tree.player == caller, 'caller not owner');
            assert(tree.last_watered_timestamp + 3600 < get_block_timestamp(), 'once an hour');
            assert(!tree.is_fruited, 'tree has fruited');

            // check water_value
            let reduction = ((get_block_timestamp() - tree.last_watered_timestamp) / 21600) * 30;
            let mut current_water_value = 0;
            let mut current_is_fruited = false;

            if (tree.water_value > reduction) {
                current_water_value = tree.water_value - reduction + 20;
            } else {
                current_water_value = 20;
            }

            if (current_water_value >= 100) {
                current_is_fruited = true;
                current_water_value = 100;
            }

            set!(
                world,
                (Tree {
                    id: tree.id,
                    player: tree.player,
                    water_value: current_water_value,
                    last_watered_timestamp: get_block_timestamp(),
                    is_fruited: current_is_fruited,
                })
            )
        }
    }
}
