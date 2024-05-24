//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import {FundiAsset} from "../Assets/FundiAsset.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//basic fund contract that can accept native cryptocurrency and ERC20s
//ownership tokenized on Fundi
contract ExampleFundiAsset is FundiAsset, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address[] public s_funders; //addresses donated
    mapping(address => uint256) private s_addressToAmountFunded;

    constructor(
        address fundiProtocol,
        uint256 fundiTokenId,
        string memory contractUri
    ) FundiAsset(fundiProtocol, fundiTokenId, contractUri) {}

    receive() external payable {
        fundBalance();
    }

    fallback() external payable {
        fundBalance();
    }

    function fundBalance() public payable nonReentrant {
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    //onlyOwner is NFT on Fundi Protocol
    function ownerWithdraw(
        address erc20,
        uint256 requestedAmt
    ) external onlyOwner {
        if (erc20 != address(0)) {
            IERC20(erc20).transfer(msg.sender, requestedAmt);
        } else {
            payable(msg.sender).transfer(requestedAmt);
        }
    }
}
