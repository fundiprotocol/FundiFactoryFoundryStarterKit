//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IFundiProtocol} from "../../src/Interfaces/IFundiProtocol.sol";
import {FundiProtocol} from "./FundiProtocol.sol";

/**
 * @title FundiAssetFactoryProtocol
 * @dev Copyright (c) 2025 Fundi Labs LLC All rights reserved.
 *
 * This source code is proprietary and confidential.
 * Unauthorized copying, modification, distribution, or use of this file,
 * via any medium, is strictly prohibited.
 *
 * For licensing inquiries, visit https://fundilabs.io
 *
 * */

contract FundiAssetFactoryProtocol is ERC721, FundiProtocol {
    using SafeERC20 for IERC20;

    struct AssetFactory {
        address contractAddress;
        uint256 tokenId;
        IFundiProtocol.AssetType assetType;
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

    struct FundiBasisPts {
        uint256 verified;
        uint256 unverified;
        uint256 customVerified;
        uint256 flagged;
    }

    error NotAuthorizedMustBeMinterOwner(address owner);
    error ContractMinterNotFoundOrInactive();
    error UnderTransferFee(uint256 transferFee);
    error MintFeeRequired(address tokenAddress, uint256 tokenMintFee);
    error AlreadyAdded();
    error NoProceeds();
    error RequestedAmtTooHigh();
    error ProtocolProceedsFailed();
    error OutOfFeeRange();
    error TokenNotSupported();
    error MinimumMintCountRequired();
    error MinterFlagged();
    error FactoryCreationFailed();

    uint16 private constant NUM_BASIS = 100;

    address public immutable i_fundiManagerAddress;
    address public immutable i_fundiManagerDao;
    address public immutable i_metadataAddress;

    uint256 public s_fundiMintFee;
    uint256 private s_tokenCounter;
    uint256 public s_assetMinterCounter;
    uint256 public s_assetFactoryFee;
    FundiBasisPts private i_fundiBasisPts;

    mapping(uint256 => FundiAssetInfo) private s_tokenIdToAsset;
    mapping(uint256 => address) private s_tokenIdToFactory;
    mapping(address => AssetFactory) private s_assetMinterInfo;
    mapping(address => uint256) private s_factoryProceeds;
    mapping(address => uint256) private s_factoryFeeProceeds;

    event NewAsset(
        uint256 indexed newTokenId,
        address indexed contractAddress,
        IFundiProtocol.AssetType contractType,
        string contractName
    );

    event NewFactory(
        uint256 indexed newTokenId,
        address indexed contractAddress,
        IFundiProtocol.AssetType contractType,
        string contractName
    );

    event FactoryVerified(
        uint256 indexed tokenId,
        address indexed contractAddress,
        bool indexed verified
    );

    event FactoryFlagUpdate(
        uint256 indexed tokenId,
        address indexed contractAddress,
        bool flagged,
        string reason
    );

    function _isAuthorizedOrOwner(address factoryAddress) private view {
        address owner = IFundiProtocol(factoryAddress).owner();
        if (_msgSender() != owner) {
            if (_msgSender() != factoryAddress) {
                revert NotAuthorizedMustBeMinterOwner(owner);
            }
        }
    }

    modifier isAuthorizedOrOwner(address factoryAddress) {
        _isAuthorizedOrOwner(factoryAddress);
        _;
    }

    function _isFactoryCreator(address factoryAddress) private view {
        address owner = IFundiProtocol(factoryAddress).creator();
        if (_msgSender() != owner) {
            revert NotAuthorizedMustBeMinterOwner(owner);
        }
    }

    modifier isFactoryCreator(address factoryAddress) {
        _isFactoryCreator(factoryAddress);
        _;
    }

    function _isOwner(address minterAddress) private view {
        address owner = IFundiProtocol(minterAddress).owner();
        if (_msgSender() != owner) {
            revert NotAuthorizedMustBeMinterOwner(owner);
        }
    }

    modifier isOwner(address minterAddress) {
        _isOwner(minterAddress);
        _;
    }

    function _assetMintable(address contractAddress) private view {
        AssetFactory memory minter = s_assetMinterInfo[contractAddress]; //Check if added
        //check if active
        if (minter.contractAddress == address(0)) {
            revert ContractMinterNotFoundOrInactive();
        }
        require(minter.active, "Minter inactive");
        require(msg.value == 0, "Must send zero ETH"); //Check if one fundi token was sent
    }

    modifier assetMintable(address contractAddress) {
        _assetMintable(contractAddress);
        _;
    }

    constructor(
        address fundiToken,
        address factoryDao,
        address fundiValidator,
        string memory _contractURI,
        address metadataAddress,
        address _owner
    )
        ERC721("Fundi Factory Protocol Mock", "FundiFactoryMock")
        FundiProtocol(fundiToken, fundiValidator, factoryDao, _contractURI)
    {
        i_metadataAddress = metadataAddress;
        s_tokenCounter = 0;
        s_assetMinterCounter = 0;
        i_fundiManagerAddress = address(this);
        i_fundiManagerDao = factoryDao;
        i_fundiBasisPts = FundiBasisPts(30, 70, 40, 90);
        //fees governable
        s_assetFactoryFee = 1000000000000000000;
        s_fundiMintFee = 500000000000000000;
    }

    function mintAssetKey(
        string memory contractName,
        address factoryAddress,
        bool transferable,
        address mintTo
    ) public nonReentrant assetMintable(factoryAddress) returns (uint256) {
        AssetFactory memory minter = s_assetMinterInfo[factoryAddress]; //Check if added

        if (mintTo == address(0)) {
            mintTo = msg.sender;
        }

        SafeERC20.safeTransferFrom(
            i_fundiToken,
            msg.sender,
            address(this),
            s_fundiMintFee
        );

        if (minter.tokenMintFee > 0) {
            uint256 balanceBefore = IERC20(minter.tokenAddress).balanceOf(
                address(this)
            );

            if (
                IERC20(minter.tokenAddress).allowance(
                    msg.sender,
                    address(this)
                ) < minter.tokenMintFee
            ) {
                revert MintFeeRequired(
                    minter.tokenAddress,
                    minter.tokenMintFee
                );
            }
            SafeERC20.safeTransferFrom(
                IERC20(minter.tokenAddress),
                msg.sender,
                address(this),
                minter.tokenMintFee
            );

            uint256 balanceAfter = IERC20(minter.tokenAddress).balanceOf(
                address(this)
            );
            if ((balanceAfter - minter.tokenMintFee) != balanceBefore) {
                revert TokenNotSupported();
            }
        }
        uint256 assetId = s_tokenCounter;
        uint256 factoryTokenId = IFundiProtocol(factoryAddress)
            .mintFundiFactoryAsset(assetId);
        s_tokenIdToAsset[assetId] = FundiAssetInfo(
            factoryAddress,
            minter.assetType,
            contractName,
            assetId,
            factoryTokenId,
            transferable
        ); //digital asset info

        _safeMint(mintTo, assetId);
        _updateProceeds(minter, factoryAddress, minter.tokenMintFee);
        s_tokenCounter = assetId + 1;

        minter.mintCount += 1;
        s_assetMinterInfo[factoryAddress] = minter;
        emit NewAsset(assetId, factoryAddress, minter.assetType, contractName);
        return (assetId);
    }

    function _updateProceeds(
        AssetFactory memory minter,
        address factoryAddress,
        uint256 assetMintFeeAmount
    ) private {
        uint256 protocolProceeds;
        uint256 currentMintFee = s_fundiMintFee;
        if (minter.verified) {
            // Pay fund creator 70% of token when verified otherwise pay 30% . Owner of contract can withdraw
            if (
                (minter.tokenMintFee == 0) ||
                (minter.tokenAddress == address(i_fundiToken))
            ) {
                //check if address right
                s_factoryProceeds[factoryAddress] += percentPayment(
                    currentMintFee,
                    10000 - (i_fundiBasisPts.verified * NUM_BASIS)
                );
                protocolProceeds = percentPayment(
                    currentMintFee,
                    (i_fundiBasisPts.verified * NUM_BASIS)
                );
            } else {
                s_factoryProceeds[factoryAddress] += percentPayment(
                    currentMintFee,
                    10000 - (i_fundiBasisPts.customVerified * NUM_BASIS)
                );
                protocolProceeds = percentPayment(
                    currentMintFee,
                    (i_fundiBasisPts.customVerified * NUM_BASIS)
                );
            }
        } else {
            if (!minter.flagged) {
                protocolProceeds = percentPayment(
                    currentMintFee,
                    (i_fundiBasisPts.unverified * NUM_BASIS)
                );
                s_factoryProceeds[factoryAddress] += percentPayment(
                    currentMintFee,
                    10000 - (i_fundiBasisPts.unverified * NUM_BASIS)
                );
            } else {
                protocolProceeds = percentPayment(
                    currentMintFee,
                    (i_fundiBasisPts.flagged * NUM_BASIS)
                );
                s_factoryProceeds[factoryAddress] += percentPayment(
                    currentMintFee,
                    10000 - (i_fundiBasisPts.flagged * NUM_BASIS)
                );
            }
        }
        if (minter.tokenMintFee > 0) {
            s_factoryFeeProceeds[factoryAddress] += assetMintFeeAmount; //confirm that tokens received
        }
    }

    function percentPayment(
        uint256 amount,
        uint256 basisPoints
    ) private pure returns (uint256) {
        return ((amount * basisPoints) / 10000);
    }

    function mintFactoryKey(
        address factory,
        IFundiProtocol.AssetType assetType,
        string memory assetName,
        address tokenAddress,
        uint256 tokenMintFee
    ) external isFactoryCreator(factory) nonReentrant returns (uint256) {
        require(
            tokenAddress != address(0),
            "Fee Token contract is the zero address"
        );

        AssetFactory memory minter = s_assetMinterInfo[factory]; //check if already exist
        if (minter.contractAddress != address(0)) {
            revert AlreadyAdded();
        }

        SafeERC20.safeTransferFrom(
            i_fundiToken,
            msg.sender,
            address(this),
            s_assetFactoryFee
        );

        uint256 factoryId = s_tokenCounter;

        if (IFundiProtocol(factory).setFundiTokenId(factoryId)) {
            _safeMint(msg.sender, factoryId);
            s_tokenIdToFactory[factoryId] = factory;
            s_assetMinterInfo[factory] = AssetFactory(
                factory,
                factoryId,
                assetType,
                assetName,
                s_assetMinterCounter,
                tokenAddress,
                tokenMintFee,
                true,
                false,
                "",
                false,
                0
            );

            s_assetMinterCounter = s_assetMinterCounter + 1;

            s_tokenCounter = factoryId + 1;

            emit NewFactory(factoryId, factory, minter.assetType, assetName);

            return (factoryId);
        } else {
            revert FactoryCreationFailed();
        }
    }

    function withdrawFundiProceeds(
        address factoryAddress,
        uint256 requestedAmt
    ) external isOwner(factoryAddress) nonReentrant {
        checkMinter(factoryAddress, requestedAmt, false);
        s_factoryProceeds[factoryAddress] -= requestedAmt;
        i_fundiToken.transfer(msg.sender, requestedAmt);
    }

    function withdrawMintFeeProceeds(
        address factoryAddress,
        uint256 requestedAmt
    ) external isOwner(factoryAddress) nonReentrant {
        checkMinter(factoryAddress, requestedAmt, true);
        AssetFactory memory minter = s_assetMinterInfo[factoryAddress];
        s_factoryFeeProceeds[factoryAddress] -= requestedAmt;
        IERC20(minter.tokenAddress).transfer(msg.sender, requestedAmt);
    }

    function checkMinter(
        address minterAddress,
        uint256 requestedAmt,
        bool customFee
    ) private view {
        uint256 proceeds;
        if (customFee) {
            proceeds = s_factoryFeeProceeds[minterAddress];
        } else {
            proceeds = s_factoryProceeds[minterAddress];
        }
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        if (requestedAmt > proceeds) {
            revert RequestedAmtTooHigh();
        }
    }

    function setAssetFactoryStatus(
        address assetMinterToUpdate,
        bool active
    ) external isAuthorizedOrOwner(assetMinterToUpdate) {
        AssetFactory memory assetMinter = s_assetMinterInfo[
            assetMinterToUpdate
        ];
        assetMinter.active = active;
        s_assetMinterInfo[assetMinterToUpdate] = assetMinter;
    }

    function verifyContract(address contractAddress) external onlyDAO {
        //check if fund added and at least 5 funds minted
        AssetFactory memory assetMinter = s_assetMinterInfo[contractAddress];
        if (assetMinter.mintCount < 5) {
            // required to avoid broken untested minters from being verified
            revert MinimumMintCountRequired();
        }
        if (!assetMinter.flagged) {
            assetMinter.verified = true;
            s_assetMinterInfo[contractAddress] = assetMinter;
            emit FactoryVerified(assetMinter.tokenId, contractAddress, true);
        } else {
            revert MinterFlagged();
        }
    }

    function updateFlag(
        address contractAddress,
        string memory reason,
        bool flagStatus
    ) external onlyDAO {
        AssetFactory memory assetMinter = s_assetMinterInfo[contractAddress]; //Check if added
        if (assetMinter.contractAddress == address(0)) {
            revert ContractMinterNotFoundOrInactive();
        }
        assetMinter.flagged = flagStatus;
        assetMinter.flagReason = reason;
        if (flagStatus) {
            assetMinter.verified = false; //test this heavily
        }
        s_assetMinterInfo[contractAddress] = assetMinter;
        emit FactoryFlagUpdate(
            assetMinter.tokenId,
            contractAddress,
            flagStatus,
            reason
        );
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(
            (s_tokenIdToAsset[tokenId].transferable ||
                (s_tokenIdToFactory[tokenId] != address(0))),
            "This asset is untransferable"
        );
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(
            (s_tokenIdToAsset[tokenId].transferable ||
                (s_tokenIdToFactory[tokenId] != address(0))),
            "This asset is untransferable"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireMinted(tokenId);
        FundiAssetInfo memory asset = s_tokenIdToAsset[tokenId];
        AssetFactory memory minter;
        if (asset.factoryAddress == address(0)) {
            minter = s_assetMinterInfo[s_tokenIdToFactory[tokenId]];
            IFundiProtocol.FactoryMetadata memory metadata = IFundiProtocol
                .FactoryMetadata(
                    uint16(minter.assetType),
                    minter.contractAddress,
                    address(this),
                    minter.tokenAddress,
                    minter.factoryNum,
                    minter.mintCount,
                    minter.tokenMintFee,
                    tokenId
                );
            return
                IFundiProtocol(i_metadataAddress).generateFactoryMetadata(
                    metadata,
                    minter.active,
                    minter.verified,
                    minter.flagged
                );
        } else {
            minter = s_assetMinterInfo[asset.factoryAddress];
            IFundiProtocol.AssetMetadata memory metadata = IFundiProtocol
                .AssetMetadata(
                    uint16(minter.assetType),
                    minter.contractAddress,
                    minter.factoryNum,
                    tokenId
                );

            return
                IFundiProtocol(i_metadataAddress).generateAssetMetadata(
                    metadata,
                    minter.verified,
                    minter.flagged,
                    asset.transferable
                );
        }
    }

    function getMinterProceeds(
        address factoryAddress
    )
        external
        view
        isAuthorizedOrOwner(factoryAddress)
        returns (uint256 fundiProceeds, uint256 feeProceeds, address token)
    {
        return (
            s_factoryProceeds[factoryAddress],
            s_factoryFeeProceeds[factoryAddress],
            s_assetMinterInfo[factoryAddress].tokenAddress
        );
    }

    function getContractURI(
        uint256 tokenId
    ) public view returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI;
        (, address assetAddress) = IFundiProtocol(
            s_tokenIdToAsset[tokenId].factoryAddress
        ).getAsset(s_tokenIdToAsset[tokenId].factoryTokenId);
        if (assetAddress != address(0)) {
            _tokenURI = IFundiProtocol(assetAddress).contractURI();
        } else {
            return "No ContractURI for tokenId";
        }
        return _tokenURI;
    }

    function getFactoryInfo(
        address factoryAddress
    ) external view returns (AssetFactory memory) {
        AssetFactory memory factory = s_assetMinterInfo[factoryAddress];
        return (factory);
    }

    function getAssetInfo(
        uint256 tokenId
    ) external view returns (FundiAssetInfo memory) {
        FundiAssetInfo memory asset = s_tokenIdToAsset[tokenId];
        return (asset);
    }

    function getFactoryInfoId(
        uint256 tokenId
    ) external view returns (AssetFactory memory) {
        address factory = s_tokenIdToFactory[tokenId];
        AssetFactory memory factoryInfo = s_assetMinterInfo[factory];
        return (factoryInfo);
    }

    function getBasisPts() external view returns (FundiBasisPts memory) {
        return (i_fundiBasisPts);
    }
}
