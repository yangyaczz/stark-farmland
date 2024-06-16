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
}


// #[derive(Drop, Serde)]
// #[dojo::model]
// struct PlayerTreeDetail {
//     #[key]
//     player: ContractAddress,
//     trees_array: Array<u128>,
// }
