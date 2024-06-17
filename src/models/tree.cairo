use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Tree {
    #[key]
    id: u128,
    player: ContractAddress,
    water_value: u64,
    last_watered_timestamp: u64,
    is_fruited: bool,
    is_harvested: bool,
// stage: TreeStage,
}


#[derive(Serde, Copy, Drop, Introspect)]
enum TreeStage {
    Seed,
    Sapling,
    Growing,
    Flowering,
    Fruiting,
    Harvesting,
}

impl TreeStageIntoFelt252 of Into<TreeStage, felt252> {
    fn into(self: TreeStage) -> felt252 {
        match self {
            TreeStage::Seed => 0,
            TreeStage::Sapling => 1,
            TreeStage::Growing => 2,
            TreeStage::Flowering => 3,
            TreeStage::Fruiting => 4,
            TreeStage::Harvesting => 5,
        }
    }
}


const TREE_MANAGER: felt252 = 'TREE_MANAGER';
#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct TreeManager {
    #[key]
    key_name: felt252,
    current_tree_id: u128,
}
