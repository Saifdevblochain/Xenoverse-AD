// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IDaoPublic.sol";


    /**
    Designer have to pay artwork submission fee 30 XEN Tokens
    Designer must hold 100 XEN Tokens to submit art
    voter must hold 1000 XEN Token
    
    */


contract DaoCommittee is  OwnableUpgradeable {
    using SafeMath for uint;
    uint private nftIndex;
    uint public committeeMembersCounter;
    IDaoPublic public DaoPublic;

    struct NFT {
        string uri;
        address owner;
        uint approvedVotes;
        uint rejectedVotes;
        bool isApprovedByCommittee;
        bool rejected;
    }

    mapping(address => bool) public Committee;

    mapping(uint => NFT) public nftStore;

    mapping(uint => mapping(address => uint8)) public committeeVoteCheck;

    event NftAdded(uint index, NFT NFT, uint uploadTime);
    event CommitteeVote(address committeeMember, uint index, bool decision, NFT _NFT);

    modifier onlyComittee() {
        require(Committee[msg.sender] == true, "Not Committee Member");
        _;
    }

    function initialize () public initializer { 
        __Ownable_init();
        Committee [msg.sender] = true;
        committeeMembersCounter++;
    }

    function addNfts ( string  calldata uri_ ) external {
        nftStore[nftIndex] = NFT(uri_,msg.sender,0,0,false,false);
        emit NftAdded(nftIndex, nftStore[nftIndex], block.timestamp);
        nftIndex++;
        DaoPublic.announceWinner();
    }

    function voteByCommittee(uint index, bool decision) public onlyComittee {
        DaoPublic.announceWinner();
        // require(committeeVoteCheck[index][msg.sender] == 0, " Already Voted ");
        require ( nftStore[index].owner != address(0), "NFT doesnot exist");
        require ( nftStore[index].isApprovedByCommittee == false, "NFT already approved" );
        require( nftStore[index].rejected == false , "NFT Rejected");
        uint votesTarget = ( committeeMembersCounter .div(2) ).add ( 1 );

        if( committeeVoteCheck[index][msg.sender] == 0 ){
            if (decision == true) {
                nftStore[index].approvedVotes++;
                committeeVoteCheck[index][msg.sender] = 1;
    
                if (nftStore[index].approvedVotes >= votesTarget) {
                    nftStore[index].isApprovedByCommittee = true;
                    DaoPublic.addInfo(nftStore[index].uri, nftStore[index].owner, true);
                }
                emit CommitteeVote(msg.sender, index, decision, nftStore[index]);
            } else {
                nftStore[index].rejectedVotes++;
                committeeVoteCheck[index][msg.sender] = 2;
    
                if (nftStore[index].rejectedVotes >= votesTarget) {
                    nftStore[index].isApprovedByCommittee = false;
                    nftStore[index].rejected =true;
                }
                emit CommitteeVote(msg.sender, index, decision, nftStore[index]);
            }
        }else if(committeeVoteCheck[index][msg.sender] == 1 && decision == false){
            nftStore[index].rejectedVotes++;
            nftStore[index].approvedVotes--;
            committeeVoteCheck[index][msg.sender] = 2;
            if (nftStore[index].rejectedVotes >= votesTarget) {
                    nftStore[index].isApprovedByCommittee = false;
                    nftStore[index].rejected =true;
                }
            emit CommitteeVote(msg.sender, index, decision, nftStore[index]);

        }else if(committeeVoteCheck[index][msg.sender] == 2 && decision == true){
            nftStore[index].rejectedVotes--;
            nftStore[index].approvedVotes++;
            committeeVoteCheck[index][msg.sender] = 1;
            if (nftStore[index].approvedVotes >= votesTarget) {
                nftStore[index].isApprovedByCommittee = true;
                DaoPublic.addInfo(nftStore[index].uri, nftStore[index].owner, true);
            }
            emit CommitteeVote(msg.sender, index, decision, nftStore[index]);
        }
    }

    function addRemoveCommitteeMember(address _address) public onlyOwner {
        if (Committee[_address] == false) {
            Committee[_address] = true;
            committeeMembersCounter++;
        } else {
            Committee[_address] = false;
            committeeMembersCounter--;
        }
    }

    function updateDaoPublicAddress(IDaoPublic _newAddress) public onlyOwner {
        DaoPublic = _newAddress;
    }
}