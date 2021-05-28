//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./WhiteElephantFactory.sol";

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract WhiteElephantGame is Ownable {
    ERC20 private ERC20interface;
    bool public _privateGame;
    // trozler - madde immutable saves gas. immutable variables can only be assigned once in constructor or at declaration.
    uint8 public immutable _maxParticipants;
    int256 public immutable _minGiftValue;
    int256 public immutable _maxGiftValue;
    Gift[] public _gifts;

    address[] public _participants;
    mapping(address => bool) private _gifted;
    mapping(address => uint32) private _order;

    // TODO: This should be set when:
    // gameStarted == true iff everyon has gifted => everyone is participating.
    bool public gameStarted = false;

    struct Gift {
        address tokenAddress;
        uint256 amount;
    }

    event GameCreated(
        int256 minGiftValue,
        int256 maxGiftValue,
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

    modifier zeroFunds() {
        require(
            address(this).balance == 0,
            "Trying to destory contract with ETH balance."
        );
        _;
    }

    // trozler - deleted WhiteElephantFactory from contract constructor.
    // Don't need this as game will never create child contract.
    constructor(
        int256 minGiftValue,
        int256 maxGiftValue,
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

    // TODO: @lorenzoPrimi
    /**
     * @dev after user has deposited funds, they will be put in a waiting area.
     * When in this waiting area the user should have the ability to have their tokens refunded.
     * any particpiant can call this function, as long as:
     *    - partcipant exists.
     *    - particpant has gifted.
     *    - game is not full.          }  gameStarted == true iff everyon has gifted => everyone is participating.
     *    - everyone has not gifted.   }
     */
    function refundGift() public {
        require(gameStarted == false, "Game has started.");

        // In reality only need to check if gifted, as gifted => participating.
        // In future can remove second require.
        require(_gifted[msg.sender] == true, "You have not gifted");
        require(_participantExists(msg.sender), "You are not participating.");

        // TODO: process refund.
    }

    function _participantExists(address participant)
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
        require(
            !_participantExists(msg.sender),
            "You are already participating"
        );
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
        // We give permission to this contract to spend the sender tokens
        return ERC20interface.approve(address(this), _amount);
    }

    function depositTokens(address tokenAddress, uint256 _amount)
        external
        payable
        hasNotGifted
    {
        ERC20interface = ERC20(tokenAddress);
        //This won't work without the price feeds implemented
        int256 price = getPrice();
        if (_minGiftValue > 0) {
            require(price > _minGiftValue, "Your gift value is too low");
        }
        if (_maxGiftValue > 0) {
            require(price < _maxGiftValue, "Your gift value is too high");
        }
        address from = msg.sender;
        address to = address(this);
        ERC20interface.transferFrom(from, to, _amount);
        _gifts.push(Gift({tokenAddress: tokenAddress, amount: _amount}));
        _gifted[from] = true;
        _checkStartGame();
        emit Transfer(msg.sender, to, _amount);
    }

    /*
     * Price feeds https://docs.chain.link/docs/reference-contracts/
     * Ethereum https://docs.chain.link/docs/ethereum-addresses/
     * Polygon https://docs.chain.link/docs/matic-addresses/
     */
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

    function transfer(
        address tokenAddress,
        address payable _to,
        uint256 _amount
    ) public payable {
        ERC20interface = ERC20(tokenAddress);
        uint256 balance = ERC20interface.balanceOf(address(this)); // the balance of this smart contract
        require(
            balance >= _amount,
            "Trying to transfer more than the smart contract balance"
        );
        ERC20interface.transferFrom(address(this), _to, balance);
    }

    // TODO: @lorenzoPrimi
    /**
     * @dev after user has deposited funds, they will be put in a waiting area.
     * When in this waiting area the user should have the ability to have their tokens refunded.
     * any particpiant can call this function, as long as:
     *    - partcipant exists.
     *    - particpant has gifted.
     *    - game is not full.
     *    - everyone has not gifted.
     *
     * gameStarted == true iff everyon has gifted => everyone is participating.
     *
     */
    function _checkStartGame() private {
        require(gameStarted == false, "Game already started.");
        require(_participants.length == _maxParticipants, "Game is not full.");

        bool hasAllGifted = true;
        for (uint32 i = 0; i < _participants.length; i++) {
            if (_gifted[_participants[i]] == false) {
                hasAllGifted = false;
            }
        }

        require(hasAllGifted, "All participants have not gifted.");

        //in this case we can start the game and call destoy before dispensed.
        startGame();
        destroy();
    }

    /**
     * @dev destroy the current contract, sending its funds to the given address.
     * selfdestruct(address payable recipient).
     * Need to be careful and make sureall funds have been
     */
    function destroy() public onlyOwner zeroFunds {
        selfdestruct(payable(owner()));
    }

    /* ---------------------------
     * These two functions will be useful when deploying the full game
     * ---------------------------
     */
    function wrapGifts() private onlyOwner {
        require(
            _participants.length == _gifts.length,
            "Not everybody has gifted"
        );
        //TODO-FUTURE wrap gift. maybe not needed in version 1
    }

    // Don't think start game should only be called by owner. That implies owner has to always be last gifter.
    function startGame() public returns (address[] memory) {
        shuffleParticipants();
        //We shuffle the participants and give gifts in order
        for (uint256 i = 0; i < _participants.length; i++) {
            Gift memory gift = _gifts[i];
            transfer(gift.tokenAddress, payable(_participants[i]), gift.amount);
        }
        return _participants;
    }

    //From SE https://ethereum.stackexchange.com/questions/74775/shuffle-array-of-integers-in-solidity
    function shuffleParticipants() private {
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
