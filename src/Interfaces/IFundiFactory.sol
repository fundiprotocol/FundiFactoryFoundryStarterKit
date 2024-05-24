//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev Required interface of an Fundi compliant contract
 */

interface IFundiFactory {
    enum AssetType {
        PAYROLL,
        TRUST,
        ESCROW,
        CROWDFUND,
        PERSONAL,
        CONTRACT,
        CUSTOM
    }

    struct AssetFactory {
        address contractAddress;
        AssetType assetType;
        string factoryName;
        uint256 factoryNum;
        address tokenAddress;
        uint256 tokenMintFee;
        bool active;
        bool flagged;
        string flagReason;
        bool verified;
        uint256 mintCount;
    }

    struct FundiAssetInfo {
        address factoryAddress;
        IFundiFactory.AssetType assetType;
        string contractName;
        uint256 tokenId;
        uint256 factoryTokenId;
        bool transferable;
    }

    function i_fundiTokenId() external view returns (uint256);

    function getAssetInfo(
        uint256 tokenId
    ) external view returns (FundiAssetInfo memory);

    function getAsset(
        uint256 factoryTokenId
    ) external view returns (uint256, address);

    function creator() external view returns (address);

    function setFundiTokenId(uint256 _tokenId) external returns (bool);

    function isFundiFactory() external returns (bool);

    function contractURI() external view returns (string memory); //get contract uri

    function getTokenUri(uint256 tokenId) external view returns (string memory);
}
