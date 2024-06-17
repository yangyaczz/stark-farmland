use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Land {
    #[key]
    id: u128,
    player: ContractAddress,
    tree_id: u128,
    is_available: bool,
}


const LAND_MANAGER: felt252 = 'LAND_MANAGER';
#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct LandManager {
    #[key]
    key_name: felt252,
    current_land_id: u128,
}
