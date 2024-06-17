#[dojo::interface]
trait IActions {
    fn spawn(ref world: IWorldDispatcher);

    fn plant(ref world: IWorldDispatcher, land_id: u128);

    fn watering_myself(ref world: IWorldDispatcher, tree_id: u128);

    fn watering_others(ref world: IWorldDispatcher, tree_id: u128); // temporary, VRF

    fn harvest(ref world: IWorldDispatcher, land_id: u128);

    fn convert_fruit_to_seed(ref world: IWorldDispatcher, fruit_amount: u128);
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

    const FRUIT_TO_SEED_RATIO: u128 = 5;
    const WATER_INTERVAL: u64 = 3600;
    const REDUCTION_INTERVAL: u64 = 21600;

    const WATER_MYSELF_INCR:u64 = 20;
    const WATER_OTHERS_INCR:u64 = 5;

    const FRUIT_AMOUNT:u128 = 30;
    const REDUCTION_AMOUNT_ONCE:u64 = 30;


    #[abi(embed_v0)]
    impl PlantActions of IActions<ContractState> {
        fn spawn(ref world: IWorldDispatcher) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));
            assert(!player.is_spawn, 'already spawn');

            let mut land_manager = get!(world, LAND_MANAGER, (LandManager));

            let land_id = land_manager.current_land_id + 1;

            set!(
                world,
                (
                    Player {
                        player: caller,
                        is_spawn: true,
                        tree_array: array![],
                        land_array: array![land_id],
                        seed_amount: 1,
                        fruit_amount: 0,
                        last_helped_timestamp: 0,
                        last_pranked_timestamp: 0,
                    },
                    LandManager { key_name: LAND_MANAGER, current_land_id: land_id, },
                    Land { id: land_id, player: caller, tree_id: 0, is_available: true, }
                )
            );
        }

        fn plant(ref world: IWorldDispatcher, land_id: u128) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));
            let mut land = get!(world, land_id, (Land));

            let mut tree_manager = get!(world, TREE_MANAGER, (TreeManager));

            assert(land.player == caller && land.is_available, 'land invaild');
            assert(player.seed_amount > 0, 'seed invaild');

            let tree_id: u128 = tree_manager.current_tree_id + 1;

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
                        is_harvested: false,
                    },
                    TreeManager { key_name: TREE_MANAGER, current_tree_id: tree_id, },
                    Land {
                        id: land.id, player: land.player, tree_id: tree_id, is_available: false,
                    },
                    Player {
                        player: player.player,
                        is_spawn: player.is_spawn,
                        tree_array: new_tree_array,
                        land_array: player.land_array,
                        seed_amount: player.seed_amount - 1,
                        fruit_amount: player.fruit_amount,
                        last_helped_timestamp: player.last_helped_timestamp,
                        last_pranked_timestamp: player.last_pranked_timestamp,
                    }
                )
            )
        }

        fn watering_myself(ref world: IWorldDispatcher, tree_id: u128) {
            let caller = get_caller_address();
            let mut tree = get!(world, tree_id, (Tree));

            // check assert
            assert(tree.player == caller, 'caller not owner');
            assert(tree.last_watered_timestamp + WATER_INTERVAL < get_block_timestamp(), 'once an hour');
            assert(!tree.is_fruited, 'tree has fruited');

            // check water_value
            let reduction = ((get_block_timestamp() - tree.last_watered_timestamp) / REDUCTION_INTERVAL) * REDUCTION_AMOUNT_ONCE;
            let mut current_water_value = 0;
            let mut current_is_fruited = false;

            if (tree.water_value > reduction) {
                current_water_value = tree.water_value - reduction + WATER_MYSELF_INCR;
            } else {
                current_water_value = WATER_MYSELF_INCR;
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
                    is_harvested: tree.is_harvested,
                })
            )
        }


        fn watering_others(ref world: IWorldDispatcher, tree_id: u128) {
            let caller = get_caller_address();
            let mut tree = get!(world, tree_id, (Tree));
            let mut player = get!(world, caller, (Player));

            assert(tree.player != caller, 'cant water myself');
            assert(player.last_helped_timestamp + WATER_INTERVAL < get_block_timestamp(), 'once an hour');
            assert(!tree.is_fruited, 'tree has fruited');

            // check water_value
            let reduction = ((get_block_timestamp() - tree.last_watered_timestamp) / REDUCTION_INTERVAL) * REDUCTION_AMOUNT_ONCE;
            let mut current_water_value = 0;
            let mut current_is_fruited = false;

            if (tree.water_value > reduction) {
                current_water_value = tree.water_value - reduction + WATER_OTHERS_INCR;
            } else {
                current_water_value = WATER_OTHERS_INCR;
            }

            if (current_water_value >= 100) {
                current_is_fruited = true;
                current_water_value = 100;
            }

            set!(
                world,
                (
                    Tree {
                        id: tree.id,
                        player: tree.player,
                        water_value: current_water_value,
                        last_watered_timestamp: tree.last_watered_timestamp,
                        is_fruited: current_is_fruited,
                        is_harvested: tree.is_harvested,
                    },
                    Player {
                        player: player.player,
                        is_spawn: player.is_spawn,
                        tree_array: player.tree_array,
                        land_array: player.land_array,
                        seed_amount: player.seed_amount,
                        fruit_amount: player.fruit_amount,
                        last_helped_timestamp: get_block_timestamp(),
                        last_pranked_timestamp: player.last_pranked_timestamp,
                    }
                )
            )
        }


        fn harvest(ref world: IWorldDispatcher, land_id: u128) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));
            let mut land = get!(world, land_id, (Land));

            // check
            assert(!land.is_available && land.tree_id != 0, 'land is empty');
            assert(land.player == caller, 'land owner not caller');

            let tree_id = land.tree_id;

            let mut tree = get!(world, tree_id, (Tree));
            assert(tree.is_fruited, 'not fruited');

            set!(
                world,
                (
                    Tree {
                        id: tree.id,
                        player: tree.player,
                        water_value: tree.water_value,
                        last_watered_timestamp: tree.last_watered_timestamp,
                        is_fruited: tree.is_fruited,
                        is_harvested: true,
                    },
                    Player {
                        player: player.player,
                        is_spawn: player.is_spawn,
                        tree_array: player.tree_array,
                        land_array: player.land_array,
                        seed_amount: player.seed_amount,
                        fruit_amount: player.fruit_amount + FRUIT_AMOUNT,
                        last_helped_timestamp: player.last_helped_timestamp,
                        last_pranked_timestamp: player.last_pranked_timestamp,
                    },
                    Land { id: land.id, player: land.player, tree_id: 0, is_available: true, }
                )
            )
        }

        fn convert_fruit_to_seed(ref world: IWorldDispatcher, fruit_amount: u128) {
            let caller = get_caller_address();
            let mut player = get!(world, caller, (Player));

            set!(
                world,
                (Player {
                    player: player.player,
                    is_spawn: player.is_spawn,
                    tree_array: player.tree_array,
                    land_array: player.land_array,
                    seed_amount: player.seed_amount + (fruit_amount / FRUIT_TO_SEED_RATIO),
                    fruit_amount: player.fruit_amount - fruit_amount,
                    last_helped_timestamp: player.last_helped_timestamp,
                    last_pranked_timestamp: player.last_pranked_timestamp,
                })
            )
        }
    }
}
