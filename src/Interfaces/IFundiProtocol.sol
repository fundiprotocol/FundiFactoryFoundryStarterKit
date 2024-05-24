//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev Required interface of an Fundi compliant contract
 */

interface IFundiProtocol {
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
        IFundiProtocol.AssetType assetType;
        string contractName;
        uint256 tokenId;
        uint256 factoryTokenId;
        bool transferable;
    }

    struct FactoryMetadata {
        uint16 assetType;
        address factoryAddress;
        address protocolAddress;
        address mintFeeTokenAddress;
        uint256 factoryID;
        uint256 factoryMintCount;
        uint256 mintFee;
        uint256 tokenID;
    }

    struct AssetMetadata {
        uint16 assetType;
        address factoryAddress;
        uint256 factoryID;
        uint256 tokenID;
    }

    function generateFactoryMetadata(
        FactoryMetadata memory metadata,
        bool factoryActive,
        bool verified,
        bool flagged
    ) external view returns (string memory);

    function generateAssetMetadata(
        AssetMetadata memory metadata,
        bool verified,
        bool flagged,
        bool transferable
    ) external view returns (string memory);

    function getAddress() external view returns (address); //return contract address

    function owner() external view returns (address); // returns owner

    function i_fundiManager() external view returns (address);

    function s_publicAudits() external view returns (uint256);

    function getAudit(
        uint256 auditId
    ) external view returns (address, string memory);

    function getContractAddress() external view returns (address);

    function i_fundiTokenId() external view returns (uint256);

    function mintCount() external view returns (uint256);

    function getAssetInfo(
        uint256 tokenId
    ) external view returns (FundiAssetInfo memory);

    function getAsset(
        uint256 factoryTokenId
    ) external view returns (uint256, address);

    function creator() external view returns (address);

    function setFundiTokenId(uint256 _tokenId) external returns (bool);

    function isFundiFactory() external returns (bool);

    function mintNewAsset(
        string memory contractName,
        uint256 contractType,
        string memory contractUri,
        address contractAddress,
        uint256 fundiTokenId,
        bool transferable
    ) external returns (address);

    function mintFundiFactoryAsset(
        uint256 fundiTokenId
    ) external returns (uint256);

    function contractURI() external view returns (string memory); //get contract uri

    function getTokenUri(uint256 tokenId) external view returns (string memory);

    function addContractAudit(string memory auditReport) external;

    function s_fundiMintFee() external view returns (uint256);

    function mintAssetKey(
        string memory contractName,
        address factoryAddress,
        bool transferable,
        address mintTo
    ) external returns (uint256);
}
