//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev Required interface of an Fundi compliant contract
 */

interface IFundiAsset {
    enum AssetType {
        PAYROLL,
        TRUST,
        ESCROW,
        CROWDFUND,
        PERSONAL_ACCOUNT,
        FINANCIAL_CONTRACT,
        INDEX_FUND,
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

    function getAddress() external view returns (address); //return contract address

    function owner() external view returns (address); // returns owner

    function creator() external view returns (address);

    function setFundiTokenId(uint256 _tokenId) external returns (bool);

    function mintNewAsset(
        string memory contractName,
        uint256 contractType,
        string memory contractUri,
        address contractAddress,
        uint256 fundiTokenId,
        bool transferable
    ) external returns (address);

    function mintFundiFactoryAsset(uint256 fundiTokenId) external;

    function contractURI() external view returns (string memory); //get contract uri

    function getTokenUri(uint256 tokenId) external view returns (string memory);

    function getFundiTokenId() external view returns (uint256);

    function i_contractName() external view returns (string memory);

    function activateContract(string memory contractUri) external;

    function i_transferable() external view returns (bool);

    function setContractURI(string memory _contractURI) external;

    function getContractType() external view returns (uint256);

    function i_fundiTokenId() external view returns (uint256);

    function i_contractFactory() external view returns (address);
}
