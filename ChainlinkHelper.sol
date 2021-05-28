//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract ChainlinkHelper {
    enum Network {
        ETHMainnet,
        ETHKovan,
        MATICMainnet,
        MATICTestnet
    }

    mapping(address => address) private feed;

    /*
     * Price feeds https://docs.chain.link/docs/reference-contracts/
     * Ethereum https://docs.chain.link/docs/ethereum-addresses/
     * Polygon https://docs.chain.link/docs/matic-addresses/
    */
    constructor(Network network) {
        if (network == Network.ETHMainnet) {
            //TODO
        }
        else if (network == Network.ETHMainnet) {
            //TODO
        }
        else if (network == Network.MATICMainnet) {
            //Token list https://explorer-mainnet.maticvigil.com/
            //AGI / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x29e5BfDe98498CaA5a8ddD73E94E47104C3A6c71;
            //BOND / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x58527C2dCC755297bB81f9334b80b2B6032d8524;
            //BTC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xc907E116054Ad103354f2D350FD2514433D57F6f;
            //DAI / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D;
            //DOT / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xacb51F1a83922632ca02B25a8164c10748001BdE;
            //ETH / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xF9680D99D6C9589e2a93a78A04A279e509205945;
            //LINK / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xd9FFdb71EbE7496cC440152d43986Aae0AB76665;
            //MATIC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
            //SAND / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x3D49406EDd4D52Fb7FFd25485f32E073b529C924;
            //SNX / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xbF90A5D9B6EE9019028dbFc2a9E50056d5252894;
            //SUSHI / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x49B0c695039243BBfEb8EcD054EB70061fd54aa0;
            //USDC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7;
            //USDT / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x0A6513e40db6EB1b165753AD52E80663aeA50545;
            //WBTC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xDE31F8bFBD8c84b5360CFACCa3539B938dd78ae6;
        }

        else if (network == Network.MATICTestnet) {
            //Token list https://explorer-mumbai.maticvigil.com/
            //DAI / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x0FCAa9c899EC5A91eBc3D5Dd869De833b06fB046;
            //ETH / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x0715A7794a1dc8e42615F059dD6e406A6594651A;
            //MATIC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;
            //USDC / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x572dDec9087154dC5dfBB1546Bb62713147e0Ab0;
            //USDT / USD
            feed[0x9b1092A76De7c2F4E95B0364C6B9a54C8c365D7B] = 0x92C09849638959196E976289418e5973CC96d645;
        }

    }

    function getPrice(address addr) private view returns (int256) {
        if(feed[addr] == address(0x0)) {
            return 0;
        }
        AggregatorV3Interface priceFeed =
            AggregatorV3Interface(feed[addr]);
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

}
