// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {SetOwnable} from "@openzeppelin/contracts/access/SetOwnable.sol";

contract FundiToken is ERC20Votes, ERC20Burnable, SetOwnable {
    //set bridge

    constructor(
        address _setOwner
    )
        ERC20("FundiMock", "FUNDIMOCK")
        ERC20Permit("FundiMock")
        SetOwnable(_setOwner)
    {
        _mint(_setOwner, 50000000 * 1e18); // should mint 0 all mint come from bridge
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
