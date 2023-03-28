// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./LinkedList.sol";

interface IXenoverse{
    function mint(address to , uint256 amount) external returns (bool);
}
 
interface IDaoCommittee {
    function committeeMembersCounter() external view returns (uint256);
    function Committee(address _add) external view returns (bool);
}

contract DaoPublic is LinkedList, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 public FIXED_DURATION;
    IXenoverse public Xenoverse;


    struct NFTInfo {
        string uri;
        address owner;
        uint256 index;
        uint256 votes;
        uint256 winTime;
        uint256 votersCount;
        uint256 favourVotes;
        uint256 disApprovedVotes;
        bool isApprovedByCommittee;
        bool winnerStatus;
        bool isBlackListed;
    }

    IDaoCommittee public daoCommittee;
    uint256 public timer;
    uint256 private nftIndex;

    uint256[] public winnersIndexes;
    mapping(uint256 => NFTInfo) public nftInfoo;
    mapping(uint256 => mapping(address => bool)) public voteCheck;
    mapping(uint256 => mapping(address => bool)) public isclaimed;

    modifier onlyDaoCommitte() {
        require(
            msg.sender == address(daoCommittee),
            "Only DaoCommittee can call"
        );
        _;
    }

    event PublicVote(address voter, uint256 index, NFTInfo _NFT);
    event NftApproved(uint256 index, NFTInfo _NFT, uint256 startTime);
    event Winner(uint256 index, NFTInfo _NFT);
    event claimed(
        address claimedBy,
        uint256 index,
        uint256 amount,
        uint256 claimTime );
    event blackListed(uint256 index, bool decision, NFTInfo _NFT);
    event voteForBlackList(
        address committeeMember,
        uint256 index,
        bool decision,
        NFTInfo _NFT
    );

    function initialize(
        IDaoCommittee _daoCommittee,
        uint256 _timer,
        uint256 FIXED_DURATION_,
        IXenoverse _xenoverse
    ) public initializer {
        __LinkedList_init();
        __Ownable_init();
        daoCommittee = _daoCommittee;
        timer = block.timestamp + _timer;
        FIXED_DURATION = FIXED_DURATION_;
        Xenoverse = _xenoverse;
    }

    function addInfo(
        string calldata uri,
        address _owner,
        bool _isApprovedByCommittee
    ) external onlyDaoCommitte {
        _addInfo(uri, _owner, _isApprovedByCommittee);
    }

    function _addInfo(
        string calldata uri,
        address _owner,
        bool _isApprovedByCommittee
    ) internal {
        nftInfoo[nftIndex] = NFTInfo(
            uri,
            _owner,
            nftIndex,
            0,
            0,
            0,
            0,
            0,
            _isApprovedByCommittee,
            false,
            false
        );
        emit NftApproved(nftIndex, nftInfoo[nftIndex], block.timestamp);
        nftIndex++;
    }

    function voteNfts(uint256 index) external {
        require(nftInfoo[index].isBlackListed == false, "Blacklisted");
        require(nftInfoo[index].winnerStatus == false, "Already winner");
        require(voteCheck[index][msg.sender] == false, "Already Voted");
        require(index < nftIndex, " Choose Correct NFT to vote ");

        NFTInfo storage nftToVote = nftInfoo[index];

        nftToVote.votes++;
        insertUp(index);
        voteCheck[index][msg.sender] = true;

        nftInfoo[index].votersCount++;
        isclaimed[index][msg.sender] = false;

        emit PublicVote(msg.sender, index, nftInfoo[index]);

        if (block.timestamp >= timer) {
            _announceWinner();
        }
    }

    function announceWinner() external {
        if (block.timestamp >= timer) {
            _announceWinner();
        }
    }

    function _announceWinner() internal {
        (bool isValid, uint256 index) = getHighest();

        if (
            isValid &&
            !nftInfoo[index].winnerStatus &&
            !nftInfoo[index].isBlackListed
        ) {
            nftInfoo[index].winnerStatus = true;
            nftInfoo[index].winTime = timer;
            winnersIndexes.push(index);
            remove(index);
            emit Winner(index, nftInfoo[index]);
            Xenoverse.mint(nftInfoo[index].owner, 720 ether);
            emit claimed(
                nftInfoo[index].owner,
                index,
                720 ether,
                block.timestamp );
        }
        uint256 dDays = (block.timestamp.sub(timer.sub(FIXED_DURATION))).div(
            FIXED_DURATION
        );
        timer = timer.add(dDays.mul(FIXED_DURATION));
    }
 
    function updateDaoCommitteeAddress(IDaoCommittee _address)
        external
        onlyOwner
    {
        daoCommittee = _address;
    }

    

    function setTimer(uint256 _FIXED_DURATION) public {
        FIXED_DURATION = _FIXED_DURATION;
    }

    function blackListArt(uint256 index, bool decision) public {
        require(nftInfoo[index].isBlackListed == false, "Already Blacklisted");
        require(
            daoCommittee.Committee(msg.sender) == true,
            "Only Committee Member can call"
        );
        uint256 votesTarget = (daoCommittee.committeeMembersCounter() / 2) + 1;

        require(
            nftInfoo[index].favourVotes < votesTarget ||
                nftInfoo[index].disApprovedVotes < votesTarget,
            "Already voted for this art"
        );
        if (block.timestamp >= timer) {
            _announceWinner();
        }

        if (decision == true) {
            nftInfoo[index].favourVotes++;
            if (nftInfoo[index].favourVotes >= votesTarget) {
                nftInfoo[index].isBlackListed = true;
                if (nftInfoo[index].votes > 0) {
                    remove(index);
                }
                emit blackListed(index, decision, nftInfoo[index]);
            }
            emit voteForBlackList(msg.sender, index, decision, nftInfoo[index]);
        } else {
            nftInfoo[index].disApprovedVotes++;
            emit voteForBlackList(msg.sender, index, decision, nftInfoo[index]);
        }
    }
}
