// Build and deploy a contract that tracks user balances 
// for a reward system. The contract should have functions 
// to add points and redeem points. Emit an event whenever
// points are added or redeemed.

use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IRewardSystem<TContractState> {
    fn add_points(ref self: TContractState, user: ContractAddress, point: u128);
    fn redeem_points(ref self: TContractState, point: u128);
    fn get_balance(self: @TContractState) -> u128;
}

#[starknet::contract]
mod RewardSystem {
    use starknet::event::EventEmitter;
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    struct Storage {
        balances: Map::<ContractAddress, u128>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PointsAdded: PointsAdded,
        PointsRedeemed: PointsRedeemed,
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct PointsAdded {
        #[key]
        user: ContractAddress,
        point: u128
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct PointsRedeemed {
        #[key]
        user: ContractAddress,
        point: u128
    }

    #[abi(embed_v0)]
    impl RewardSystem of super::IRewardSystem<ContractState> {
        fn add_points(ref self: ContractState, user: ContractAddress, point: u128) {
            self.balances.entry(user).write(point);
            self.emit(PointsAdded { user: user, point: point });
        }

        fn redeem_points(ref self: ContractState, point: u128) {
            let caller = get_caller_address();
            let user_point_balance = self.balances.entry(caller).read();

            assert!(user_point_balance >= point);
            let new_user_point_balance = user_point_balance - point;

            assert!(new_user_point_balance >= 0);
            self.balances.entry(caller).write(new_user_point_balance);

            self.emit(PointsRedeemed {user: caller, point: point});
        }

        fn get_balance(self: @ContractState) -> u128 {
            let caller = get_caller_address();
            self.balances.entry(caller).read()
        }
    }

    #[external(v0)]
    pub fn get_contract_name(self: @ContractState) -> felt252 {
        'Point Reward System'
    }
}