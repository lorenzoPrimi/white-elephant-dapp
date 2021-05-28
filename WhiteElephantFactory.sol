//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./WhiteElephantGame.sol";

contract WhiteElephantFactory {
    WhiteElephantGame[] public games;

    function createGame(
        int256 minGiftValue,
        int256 maxGiftValue,
        bool privateGame,
        uint8 maxParticipants
    ) public returns (WhiteElephantGame tokenAddress) {
        WhiteElephantGame game =
            new WhiteElephantGame(
                minGiftValue,
                maxGiftValue,
                privateGame,
                maxParticipants
            );
        game.transferOwnership(msg.sender);
        games.push(game);
        return game;
    }

    function createGameAndSendEther(
        int256 minGiftValue,
        int256 maxGiftValue,
        bool privateGame,
        uint8 maxParticipants
    ) public payable returns (WhiteElephantGame tokenAddress) {
        WhiteElephantGame game =
            new WhiteElephantGame(
                minGiftValue,
                maxGiftValue,
                privateGame,
                maxParticipants
            );
        game.transferOwnership(msg.sender);
        games.push(game);
        return game;
    }

    function getGame(uint256 _index)
        public
        view
        returns (
            address owner,
            int256 minGiftValue,
            int256 maxGiftValue,
            bool privateGame,
            uint8 maxParticipants,
            uint256 balance
        )
    {
        WhiteElephantGame game = games[_index];
        return (
            game.owner(),
            game._minGiftValue(),
            game._maxGiftValue(),
            game._privateGame(),
            game._maxParticipants(),
            address(game).balance
        );
    }
}
