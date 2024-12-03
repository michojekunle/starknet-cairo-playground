
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
    fn create_auction(ref self: TContractState, name: felt252, nft_id: u128, duration: u128);
    fn end_auction(ref self: TContractState, auction_id: u128);
    fn place_bid(self: @TContractState, auction_id: u128);
    fn get_auction(self: @TContractState) -> Auction;
}

#[starknet::contract]
mod AuctionContract {
    use starknet::event::EventEmitter;
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    struct Storage {
        auctions: Map::<u128, Auction>,
        no_of_auctions: u128,
    }

    #[event]
    #[derive(Drop)]
    enum Event {
        AuctionCreated: AuctionCreated,
        AuctionEnded: AuctionEnded,
        BidPlaced: BidPlaced
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
        bidder: ContractAddress,
        bid: u128
    }

    #[derive(Drop, starknet::Store)]
    pub struct Auction {
        name: felt252,
        seller: ContractAddress,
        nft_id: u128,
        duration: u128,
        highest_bidder: ContractAddress,
        highest_bid: u128,
        bids: Map<ContractAddress, u128>
    }


    #[abi(embed_v0)]
    impl Auction of super::IAuction<ContractState> {
        fn create_auction()
    }

    #[external(v0)]
    pub fn get_contract_name(self: @ContractState) -> felt252 {
        'Auction Contract'
    }
}