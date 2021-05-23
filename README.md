# White Elephant Gift Exchange
A popular US holiday gift giving game known as “White Elephant” involves blindly choosing from a group of wrapped gifts or stealing an already unwrapped gift from a previous player. Play continues until all players have an unwrapped gift in their hands.


### Goals
Develop the “White Elephant Gift Exchange” decentralized gift giving exchange, this dApp aims to create a sense of fun and excitement based on the idea of mystery gifts.


### What it does
Allows players to offer an ERC20 token of their choice as a gift to another random player as well as receiving a mystery gift, the fun part of this game is that any player can choose any ERC20 token from their wallet and the organizer can even set a minimum or maximum value for the gifts, calculated at the moment of sending it.
All ERC20 winnings from the White Elephant game will be transferred securely back to your wallet at the end, who knows how high your winnings can go if you HODL!


### Rules:
1. Every player deposits a ERC20 token of their choice into the smart contract.
2. Every gift will be checked when depositing to ensure that it fits the requirements (ERC20, value amount, etc.)
3. The game cannot start until the required number of players required have joined. (20 players would be a great starting point for this game)
4. Each player will be assigned a random number from 1 to the number of players.
5. Each gift must also have an assigned random number and it’s gonna be wrapped. When a gift is "wrapped," it loses most of its identifying information. (Some tweaks needed here so gift givers can't cheat.)
6. The person who was randomly chosen to be the first player will choose a random gift and unwrap it. This reveals what type of ERC token and value it is to all members of the gift exchange.
7. Every subsequent player can either steal one of the previously opened gifts from another player or unwrap a new gift.
8. If a player steals a gift :
	-   The gift will be marked as stolen 1 time; after 3 times, it can’t be stolen anymore.
	-   The player who got his gift stolen can unwrap a new gift or steal another gift. The player can’t steal a gift back right away (i.e., a gift that was just stolen from him)
9. The game continues until every player has chosen a gift, in which case the gifts are distributed.
10. Player #1 takes one more turn at the end, since he started the game without having a chance to steal
11. The game ends


### Requirements:
1. Gifts must be ERC20 tokens
2. The number of participants is limited and set when the smart contract is deployed. The game can be invite only or open to everybody until it reaches the required number of participants.
3. Whoever deploys the smart contract can choose a minimum or/and a maximum value for every gift. If this option is set the value of the gift is checked from Chainlink oracles at the moment of submission and the gift can be approved or rejected.
