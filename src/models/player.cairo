use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress,
    is_spawn: bool,
    tree_array: Array<u128>,
    land_array: Array<u128>,
    seed_amount: u128,
    fruit_amount: u128,
    last_helped_timestamp: u64,
    last_pranked_timestamp: u64,
}

