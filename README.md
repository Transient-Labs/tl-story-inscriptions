# Transient Labs Story Contract
Developed in collaboration with Michelle Viljoen, the Transient Labs Story Contract enables new ways for artists and collectors to experience and add to their art, while creating news ways for all to experience and discover art. This is Social Art, not social media.

## 1. Problem Statement
Art has so much more to it than just the piece of art itself. There is the story of the artist, the inspiration behind the piece of art, and the story from each collector of the piece.

There is no easy way to have all of these stories available to potential collectors and the community as a whole. Typically, it’s just verbally relayed amongst all parties.

In crypto art, piece descriptions get us part of the way there… but we can do so much better by leveraging blockchain technology.

## 2. Current State of the System
Currently, crypto artists and their stories are relayed to collectors via Twitter, marketplace bios (which are typically short and hard to find), and art descriptions.

Sometimes collectors will tweet about why they collected a piece, but generally these stories are hard to find unless you’ve saved the tweet somewhere.

This space keeps talking about storytelling… but has yet to have a good way to tell these stories immutably.

## 3. Story Contract Solution
Originally developed as a collaboration with Michelle Viljoen, the Story Contract was developed to overcome the limitations of traditional storytelling.

This contract allows both the artist and collector(s) can write their stories to the blockchain, where they are stored immutably and for infinitum, without censorship. 

Transient Labs plans to provide a new experience where people can explore stories, in general or for a specific piece of art. We are also working with marketplaces to get this integrated.

## 4. ERC-165 Support
The Story Contract supports ERC-165. The Interface ID is `0xd23ecb9`

## 5. Gas Cost
Based on local testing, the gas cost of a 5000 word story (a research paper) costs `694795 gas`. At 100 gwei gas, this coverts to a gas cost of `0.0694795 ETH`. This is extrememly gas efficient. Stories will also likely be much shorter in length and submitted when gas is lower.

## Testing
You should run the test suite with `make test_suite`. 

This loops through the following solidity versions:
- 0.8.17
- 0.8.18
- 0.8.19
- 0.8.20

Any untested Solidity versions are NOT reccomended for use.

## Disclaimer
This codebase is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

## License
This code is copyright Transient Labs, Inc 2022 and is licensed under the MIT license.