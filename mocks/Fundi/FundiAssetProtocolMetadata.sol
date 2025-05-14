// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FundiAssetProtocolMetadata
 * @dev Copyright (c) 2025 Fundi Labs LLC All rights reserved.
 *
 * This source code is proprietary and confidential.
 * Unauthorized copying, modification, distribution, or use of this file,
 * via any medium, is strictly prohibited.
 *
 * For licensing inquiries, visit https://fundilabs.io
 *
 * */

contract FundiAssetProtocolMetadata {
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

    string internal constant _baseURI = "data:application/json;base64,";
    string[] public i_unverifiedTokenURIs = [
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedPayrollAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedTrustAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedEscrowAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedCrowdfundAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedPersonalAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedContractAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/UnverifiedCustomAsset.jpg"
    ];

    string[] public i_verifiedTokenURIs = [
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedPayrollAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedTrustAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedEscrowAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedCrowdfundAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedPersonalAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedContractAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/VerifiedCustomAsset.jpg"
    ];

    string[] public i_flaggedTokenURIs = [
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedPayrollAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedTrustAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedEscrowAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedCrowdfundAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedPersonalAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedContractAsset.jpg",
        "ipfs://QmPWmnxx2A2vxAYKdW6TND4qJB6bB7Q2rBuxfdk52H8rpD/FlaggedCustomAsset.jpg"
    ];

    string[] public i_unverifiedFactoryURIs = [
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedPayrollFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedTrustFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedEscrowFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedCrowdfundFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedPersonalFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedContractFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/UnverifiedCustomFactory.jpg"
    ];

    string[] public i_verifiedFactoryURIs = [
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedPayrollFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedTrustFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedEscrowFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedCrowdfundFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedPersonalFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedContractFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/VerifiedCustomFactory.jpg"
    ];

    string[] public i_flaggedFactoryURIs = [
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedPayrollFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedTrustFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedEscrowFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedCrowdfundFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedPersonalFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedContractFactory.jpg",
        "ipfs://QmVDB7JCDX3LNaSi3hhFkab5BZL4gZRrCHjiU3rczLngcU/FlaggedCustomFactory.jpg"
    ];

    function generateFactoryMetadata(
        FactoryMetadata memory metadata,
        bool factoryActive,
        bool verified,
        bool flagged
    ) external view returns (string memory) {
        string memory assetType = assetTypeToString(metadata.assetType);
        string memory imageURI;
        string memory description;

        string memory tokenId = Strings.toString(metadata.tokenID);
        string memory tokenName = string(
            abi.encodePacked(assetType, " Factory ", tokenId)
        );
        string memory factoryAddress = Strings.toHexString(
            metadata.factoryAddress
        );
        string memory active = (factoryActive) ? "Active" : "Inactive";
        if (verified) {
            imageURI = i_verifiedFactoryURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Verified Fundi ',
                    tokenName,
                    '", "description":"This is a key for a Verified ',
                    assetType,
                    " Factory that was minted from Fundi Protocol ",
                    Strings.toHexString(metadata.protocolAddress),
                    ". For more information regarding this factory, run the getContractURI(",
                    tokenId,
                    ") and getFactoryInfo(",
                    factoryAddress,
                    ') functions from the Fundi Protocol", "image":"',
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Factory"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Verified"}, {"trait_type": "Status", "value": "',
                    active
                )
            );
        } else if (flagged) {
            imageURI = i_flaggedFactoryURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Flagged Fundi ',
                    tokenName,
                    '", "description":"This is a key for a Flagged ',
                    assetType,
                    " Factory that was minted from Fundi Protocol ",
                    Strings.toHexString(metadata.protocolAddress),
                    ". For more information regarding this factory, run the getContractURI(",
                    tokenId,
                    ") and getFactoryInfo(",
                    factoryAddress,
                    ') functions from the Fundi Protocol", "image":"',
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Factory"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Flagged"}, {"trait_type": "Status", "value": "',
                    active
                )
            );
        } else {
            imageURI = i_unverifiedFactoryURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Unverified Fundi ',
                    tokenName,
                    '", "description":"This is a key for a Unverified ',
                    assetType,
                    " Factory that was minted from Fundi Protocol ",
                    Strings.toHexString(metadata.protocolAddress),
                    ". For more information regarding this factory, run the getContractURI(",
                    tokenId,
                    ") and getFactoryInfo(",
                    factoryAddress,
                    ') functions from the Fundi Protocol", "image":"',
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Factory"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Unverified"}, {"trait_type": "Status", "value": "',
                    active
                )
            );
        }
        description = string(
            abi.encodePacked(
                description,
                // active,
                '"}, {"trait_type": "Factory Contract Address", "value": "',
                factoryAddress,
                '"}, {"trait_type": "Factory ID", "value": "',
                Strings.toString(metadata.factoryID),
                '"}, {"trait_type": "Factory Mint Count", "value": "',
                Strings.toString(metadata.factoryMintCount),
                '"}, {"trait_type": "Mint Fee Currency", "value": "'
            )
        );
        description = string(
            abi.encodePacked(
                description,
                Strings.toHexString(metadata.mintFeeTokenAddress),
                '"}, {"trait_type": "Mint Fee", "value": "',
                Strings.toString(metadata.mintFee),
                '"}]}'
            )
        );

        return
            string(
                abi.encodePacked(_baseURI, Base64.encode(bytes(description)))
            );
    }

    function generateAssetMetadata(
        AssetMetadata memory metadata,
        bool verified,
        bool flagged,
        bool transferable
    ) external view returns (string memory) {
        string memory assetType = assetTypeToString(metadata.assetType);
        string memory imageURI;
        string memory description;
        string memory tokenId = Strings.toString(metadata.tokenID);
        string memory tokenFunctions = string(
            abi.encodePacked(
                ". For more information regarding this asset, run the getContractURI(",
                tokenId,
                ") and getAssetInfo(",
                tokenId,
                ') functions from the Fundi Protocol", "image":"'
            )
        );
        string memory factoryAddress = Strings.toHexString(
            metadata.factoryAddress
        );
        string memory transfer = (transferable) ? "Yes" : "No";
        if (verified) {
            imageURI = i_verifiedTokenURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Verified Fundi ',
                    assetType,
                    " Asset ",
                    tokenId,
                    '", "description":"This is a key for a Verified ',
                    assetType,
                    " Asset that was minted from Fundi Factory ",
                    factoryAddress,
                    tokenFunctions,
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Asset"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Verified"}, {"trait_type": "Factory Contract Address", "value": "'
                )
            );
        } else if (flagged) {
            imageURI = i_flaggedTokenURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Flagged Fundi ',
                    assetType,
                    " Asset ",
                    tokenId,
                    '", "description":"This is a key for a Flagged ',
                    assetType,
                    " Asset that was minted from Fundi Factory ",
                    factoryAddress,
                    tokenFunctions,
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Asset"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Flagged"}, {"trait_type": "Factory Contract Address", "value": "'
                )
            );
        } else {
            imageURI = i_unverifiedTokenURIs[metadata.assetType];
            description = string(
                abi.encodePacked(
                    '{"name":"Unverified Fundi ',
                    assetType,
                    " Asset ",
                    tokenId,
                    '", "description":"This is a key for a Unverified ',
                    assetType,
                    " Asset that was minted from Fundi Factory ",
                    factoryAddress,
                    tokenFunctions,
                    imageURI,
                    '", "external_url":"fundilabs.io", "aboutFundi":"Fundi is an open verifiable network of tokenized validators and protocols that mints keys to tokenize digital contracts and assets.", "chainID":"11155111", "attributes": [{"trait_type": "Asset Type", "value": "Asset"}, {"trait_type": "Contract Type", "value": "',
                    assetType,
                    '"}, {"trait_type": "Verification Status", "value": "Unverified"}, {"trait_type": "Factory Contract Address", "value": "'
                )
            );
        }
        description = string(
            abi.encodePacked(
                description,
                factoryAddress,
                '"}, {"trait_type": "Factory ID", "value": "',
                Strings.toString(metadata.factoryID),
                '"}, {"trait_type": "Transferable", "value": "',
                transfer,
                '"}]}'
            )
        );

        return
            string(
                abi.encodePacked(_baseURI, Base64.encode(bytes(description)))
            );
    }

    function assetTypeToString(
        uint16 _assetType
    ) internal pure returns (string memory) {
        if (_assetType == 0) {
            return "Payroll";
        } else if (_assetType == 1) {
            return "Trust";
        } else if (_assetType == 2) {
            return "Escrow";
        } else if (_assetType == 3) {
            return "Crowdfund";
        } else if (_assetType == 4) {
            return "Personal";
        } else if (_assetType == 5) {
            return "Contract";
        } else if (_assetType == 6) {
            return "Custom";
        } else {
            return "Unknown";
        }
    }
}
