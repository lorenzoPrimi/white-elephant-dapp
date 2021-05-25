//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract WhiteElephant is Ownable {
    // Variable packing to optimsie gas costs.
    bool public _privateGame;
    uint8 public _maxParticipants;
    ERC20 private ERC20interface;
    uint256 public _minGiftValue;
    uint256 public _maxGiftValue;
    address[] public _participants;
    Gift[] public _gifts;
    mapping(address => bool) _gifted;
    mapping(address => uint32) _order;

    struct Gift {
        address tokenAdress;
        uint256 amount;
    }

    constructor(
        uint256 minGiftValue,
        uint256 maxGiftValue,
        bool privateGame,
        uint8 maxParticipants
    ) {
        _minGiftValue = minGiftValue;
        _maxGiftValue = maxGiftValue;
        _privateGame = privateGame;
        _maxParticipants = maxParticipants;
        emit GameCreated(
            minGiftValue,
            maxGiftValue,
            privateGame,
            maxParticipants,
            block.timestamp
        );
    }

    event GameCreated(
        uint256 minGiftValue,
        uint256 maxGiftValue,
        bool privateGame,
        uint8 maxParticipants,
        uint256 timestamp
    );

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    modifier spotsAvailable() {
        require(_participants.length < _maxParticipants, "The game is full");
        _;
    }

    modifier canJoinGame() {
        require(_privateGame == false, "This is a private game");
        _;
    }

    modifier hasNotGifted() {
        require(_gifted[msg.sender] == false, "You have already gifted");
        _;
    }

    // Private scope if only intend to use in isParticipating modifier.
    function participantExists(address participant)
        private
        view
        returns (bool)
    {
        for (uint256 i = 0; i < _participants.length; ++i) {
            if (_participants[i] == participant) {
                return true;
            }
        }
        return false;
    }

    function joinGame() private canJoinGame spotsAvailable {
        require(!participantExists(msg.sender), "You are already participating");
            _participants.push(msg.sender);
    }

    function addParticipants(address[] memory participants) public onlyOwner {
        require(
            participants.length + _participants.length <= _maxParticipants,
            "Too many participants added"
        );
        for (uint256 i = 0; i < participants.length; ++i) {
            if (_participants.length < _maxParticipants) {
                _participants.push(participants[i]);
                console.log("adding participant ", participants[i]);
            }
        }
    }

    function approveSpendToken(address tokenAdress, uint256 _amount)
        public
        returns (bool)
    {
        ERC20interface = ERC20(tokenAdress);
        emit Approval(msg.sender, address(this), _amount);
        return ERC20interface.approve(address(this), _amount); // We give permission to this contract to spend the sender tokens
    }

    function depositTokens(address tokenAdress, uint256 _amount)
        external
        payable
        hasNotGifted
    {
        ERC20interface = ERC20(tokenAdress);
        //TODO check the price of the gift getPrice() or don't do the transfer
        address from = msg.sender;
        address to = address(this);
        ERC20interface.transferFrom(from, to, _amount);
        _gifts.push(Gift({
            tokenAdress: tokenAdress,
            amount: _amount
        }));
        _gifted[from] = true;
        checkStartGame();
        emit Transfer(msg.sender, to, _amount);
    }

    //TODO pass as argument the token name / address
    function getPrice() private view returns (int256) {
        AggregatorV3Interface priceFeed =
            AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    /*
    //TODO for later when giving gifts
    function transferBack (address payable _to) public payable  {
        _to = msg.sender;
        uint balance = ERC20interface.balanceOf(address(this)); // the balance of this smart contract
        ERC20interface.transferFrom(address(this), _to, balance);
    }
*/

    function checkStartGame() private {
        if (_participants.length == _maxParticipants &&
        _participants.length == _gifts.length) {
            //in this case we can start the game, everybody has gifted and we can distribute gifts back
        }
    }

    /* ---------------------------
     * These two functions will be useful when deploying the full game
     * ---------------------------
     */
    function wrapGifts() private onlyOwner {
        require(_participants.length == _gifts.length, "Not everybody has gifted");
        //TODO-FUTURE wrap gift. maybe not needed in version 1
    }

    function startGame() public onlyOwner returns (address[] memory) {
        require(
            _participants.length == _maxParticipants,
            "The game is not full"
        );
        shuffleParticipants();
        return _participants;
    }

    //From SE https://ethereum.stackexchange.com/questions/74775/shuffle-array-of-integers-in-solidity
    function shuffleParticipants() private onlyOwner {
        for (uint256 i = 0; i < _participants.length; i++) {
            uint256 n =
                i +
                    (uint256(keccak256(abi.encodePacked(block.timestamp))) %
                        (_participants.length - i));
            address temp = _participants[n];
            _participants[n] = _participants[i];
            _participants[i] = temp;
        }
    }
}
