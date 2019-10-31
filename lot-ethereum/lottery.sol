/* Orchid - WebRTC P2P VPN Market (on Ethereum)
 * Copyright (C) 2017-2019  The Orchid Authors
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */


pragma solidity ^0.5.7;

import "../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract OrchidLottery {

    IERC20 internal token_;

    constructor(address token) public {
        token_ = IERC20(token);
    }


    struct Pot {
        uint256 offset_;

        uint128 amount_;
        uint128 escrow_;

        uint256 unlock_;
    }

    event Update(address indexed funder, address indexed signer, uint128 amount, uint128 escrow, uint256 unlock);

    function send(address funder, address signer, Pot storage pot) private {
        emit Update(funder, signer, pot.amount_, pot.escrow_, pot.unlock_);
    }


    struct Lottery {
        address[] keys_;
        mapping(address => Pot) pots_;
    }

    mapping(address => Lottery) internal lotteries_;


    function find(address funder, address signer) private view returns (Pot storage) {
        return lotteries_[funder].pots_[signer];
    }

    function kill(address funder, address signer, Pot storage pot) private {
        Lottery storage lottery = lotteries_[funder];
        require(pot.offset_ != 0);
        lottery.keys_[pot.offset_ - 1] = lottery.keys_[lottery.keys_.length];
        --lottery.keys_.length;
        delete lottery.pots_[signer];
    }


    function size(address funder) public view returns (uint256) {
        return lotteries_[funder].keys_.length;
    }

    function keys(address funder) public view returns (address[] memory) {
        return lotteries_[funder].keys_;
    }

    function seek(address funder, uint256 offset) public view returns (address) {
        return lotteries_[funder].keys_[offset];
    }


    function look(address funder, address signer) public view returns (uint128, uint128, uint256) {
        Pot storage pot = lotteries_[funder].pots_[signer];
        return (pot.amount_, pot.escrow_, pot.unlock_);
    }


    function push(address signer, uint128 amount, uint128 total) public {
        address funder = msg.sender;
        require(total >= amount);
        Pot storage pot = find(funder, signer);
        if (pot.offset_ == 0)
            pot.offset_ = lotteries_[funder].keys_.push(signer);
        pot.amount_ += amount;
        pot.escrow_ += total - amount;
        send(funder, signer, pot);
        require(token_.transferFrom(funder, address(this), total));
    }

    function move(address signer, uint128 amount) public {
        address funder = msg.sender;
        Pot storage pot = find(funder, signer);
        require(pot.amount_ >= amount);
        pot.amount_ -= amount;
        pot.escrow_ += amount;
        send(funder, signer, pot);
    }


    struct Track {
        uint256 until_;
    }

    mapping(address => mapping(bytes32 => Track)) internal tracks_;

    function kill(Track storage track) private {
        require(track.until_ <= block.timestamp);
        delete track.until_;
    }

    function kill(bytes32 ticket) public {
        kill(tracks_[msg.sender][ticket]);
    }


    function take(address funder, address signer, uint128 amount) private returns (uint128) {
        Pot storage pot = find(funder, signer);

        if (pot.amount_ >= amount)
            pot.amount_ -= amount;
        else {
            amount = pot.amount_;
            kill(funder, signer, pot);
        }

        send(funder, signer, pot);
        return amount;
    }

    function grab(uint256 secret, bytes32 hash, address payable target, address funder, uint256 nonce, uint256 ratio, uint256 start, uint128 range, uint128 amount, uint8 v, bytes32 r, bytes32 s, bytes32[] memory old) public {
        require(keccak256(abi.encodePacked(secret)) == hash);
        require(uint256(keccak256(abi.encodePacked(secret, nonce))) < ratio);

        bytes32 ticket = keccak256(abi.encodePacked(hash, target, funder, nonce, ratio, start, range, amount));

        {
            uint256 until = start + range;
            require(until > block.timestamp);
            require(tracks_[target][ticket].until_ == 0);
            tracks_[target][ticket].until_ = until;
        }

        for (uint256 i = 0; i != old.length; ++i)
            kill(tracks_[target][old[i]]);

        {
            uint128 limit;
            if (start >= block.timestamp)
                limit = amount;
            else
                limit = uint128(uint256(amount) * (range - (block.timestamp - start)) / range);

            address signer = ecrecover(ticket, v, r, s);
            require(signer != address(0));

            amount = take(funder, signer, amount);
            if (amount > limit)
                amount = limit;
        }

        if (amount != 0)
            require(token_.transfer(target, amount));
    }

    function pull(address signer, address payable target, uint128 amount) public {
        address funder = msg.sender;
        amount = take(funder, signer, amount);
        require(token_.transfer(target, amount));
    }


    function warn(address signer) public {
        address funder = msg.sender;
        Pot storage pot = find(funder, signer);
        pot.unlock_ = block.timestamp + 1 days;
        send(funder, signer, pot);
    }

    function lock(address signer) public {
        address funder = msg.sender;
        Pot storage pot = find(funder, signer);
        pot.unlock_ = 0;
        send(funder, signer, pot);
    }

    function pull(address signer, address payable target) public {
        address funder = msg.sender;
        Pot storage pot = find(funder, signer);
        require(pot.unlock_ != 0);
        require(pot.unlock_ <= block.timestamp);
        uint128 amount = pot.amount_ + pot.escrow_;
        kill(funder, signer, pot);
        send(funder, signer, pot);
        require(token_.transfer(target, amount));
    }
}
