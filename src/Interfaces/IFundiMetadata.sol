pragma solidity ^0.8.17;

interface IFundiMetadata {
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

    struct ValidatorMetadata {
        address contractAddress;
        uint256 validatorId;
        string contractUri;
        bool verificationStatus; //verified or unverified
        bool flagged;
        bool active;
    }

    struct ProtocolMetadata {
        address contractAddress;
        uint256 tokenId;
        string contractUri;
        address tokenAddress;
        bool verificationStatus; //active or inactive
        bool flagged;
        bool active;
        address validatorAddress;
    }

    function generateFactoryMetadata(
        FactoryMetadata calldata metadata,
        bool factoryActive,
        bool verified,
        bool flagged
    ) external view returns (string memory);

    function generateAssetMetadata(
        AssetMetadata calldata metadata,
        bool verified,
        bool flagged,
        bool transferable
    ) external view returns (string memory);

    function generateValidatorMetadata(
        ValidatorMetadata calldata _validator
    ) external pure returns (string memory);

    function generateProtocolMetadata(
        ProtocolMetadata calldata _validator
    ) external pure returns (string memory);
}
