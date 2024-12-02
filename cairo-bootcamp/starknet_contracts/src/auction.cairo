
// Write and deploy an auction contract in cairo starknet 
// where users can place bids for an NFT. The highest 
// bidder at the end of the auction wins. Deploy the 
// contract on Devnet and simulate several bidding 
// rounds to test the functionality.

// users should be able to create auction, place bids and only 
// end auction when tiime for auction has ended and should 
// only be able to place bids when the auction hash not ended

use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IAuction<TContractState> {
    fn create_auction(ref self: TContractState, user: ContractAddress, point: u128);
    fn end_auction(ref self: TContractState, point: u128);
    fn place_bid(self: @TContractState) -> u128;
}

#[starknet::contract]
mod Auction {
    use starknet::event::EventEmitter;
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerWriteAccess, StoragePointerReadAccess};

    #[derive(Drop, Serde, Copy, starknet::Store)]
    struct Auction {
        name: felt252,
        nft_id: u128,
        duration: u128,
        highest_bidder: ContractAddress,
        highest_bid: u128,
        bids: Map<ContractAddress, u128>[],
    }

    #[storage]
    struct Storage {
        auctions: Map::<ContractAddress, Auction>,
        no_of_auctions: u128,
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct AuctionCreated {
        #[key]
        creator: ContractAddress,
        nft_id: u128,
        duration: u128,
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct AuctionEnded {
        #[key]
        auction_id: u128,
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct BidPlaced {
        #[key]
        auction_id: u128,
        bid: u128,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AuctionCreated: AuctionCreated,
        AuctionEnded: AuctionEnded,
        BidPlaced: BidPlaced
    }


    #[abi(embed_v0)]
    impl Auction of super::IAuction<ContractState> {
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

            self.emit(AuctionEnded {user: caller, point: point});
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