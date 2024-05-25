//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IFundiProtocol} from "../Interfaces/IFundiProtocol.sol";

//This implementation is the smart contract that you want the factory to mint and tokenize

contract FundiAsset is Context {
    string[] public i_fundiURIs = [
        "PAYROLL",
        "TRUST",
        "ESCROW",
        "CROWDFUND",
        "PERSONAL_ACCOUNT",
        "CONTRACT",
        "CUSTOM"
    ];

    uint256 public immutable i_fundiTokenId;
    uint256 public immutable i_factoryTokenId;
    string public i_contractName;
    uint256 private immutable i_contractType;
    string public s_contractURI; //info could be immutable for some use cases
    address public immutable i_contractFactory;
    address public immutable i_contractAddress;
    address public immutable i_fundiProtocol;
    bool public immutable i_transferable;

    error NotOwner();

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    constructor(
        address fundiProtocol,
        uint256 fundiTokenId,
        string memory contractUri
    ) {
        IFundiProtocol.FundiAssetInfo memory fundiAsset = IFundiProtocol(
            fundiProtocol
        ).getAssetInfo(fundiTokenId);

        //assigns immutable contract variables
        i_contractAddress = address(this);
        i_fundiTokenId = fundiTokenId;
        i_factoryTokenId = fundiAsset.factoryTokenId;
        i_contractName = fundiAsset.contractName;
        i_contractType = uint256(fundiAsset.assetType);
        i_contractFactory = fundiAsset.factoryAddress;
        i_transferable = fundiAsset.transferable;
        s_contractURI = contractUri;
        i_fundiProtocol = fundiProtocol;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return IERC721(i_fundiProtocol).ownerOf(i_fundiTokenId);
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view {
        address assetOwner = IERC721(i_fundiProtocol).ownerOf(i_fundiTokenId);
        if (_msgSender() != assetOwner) {
            revert NotOwner();
        }
    }

    function setContractURI(string memory _contractURI) external onlyOwner {
        s_contractURI = _contractURI; //have documentation here with website and cause
    }

    function contractURI() external view virtual returns (string memory) {
        return s_contractURI;
    }

    function getContractAddress() external view virtual returns (address) {
        return i_contractAddress;
    }

    function getContractType()
        external
        view
        virtual
        returns (uint256 contractType)
    {
        return i_contractType;
    }

    function getFundiTokenId() external view virtual returns (uint256) {
        return i_fundiTokenId;
    }
}
