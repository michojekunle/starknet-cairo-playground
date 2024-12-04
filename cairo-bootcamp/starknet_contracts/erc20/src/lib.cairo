/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
/// 

use starknet::ContractAddress;

#[starknet::interface]
pub trait INatToken<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256); 
}

/// Simple contract for managing balance.
#[starknet::contract]
mod NatToken {
    use ERC20Component::InternalTrait;
    use openzeppelin::token::erc20:: { ERC20Component, ERC20HooksEmptyImpl };
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }
    
    #[constructor]
    fn constructor(ref self: ContractState) {
        self.erc20.initializer("Nat Token", "NAT");
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20MixinImpl<ContractState>;

    #[abi(embed_v0)]
    impl NatTokenImpl of super::INatToken<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.erc20.mint(recipient, amount);
        }
    }
}
