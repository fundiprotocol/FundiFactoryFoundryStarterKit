//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IFundiFactory} from "../Interfaces/IFundiFactory.sol";

contract FundiFactory is Context, ReentrancyGuard {
    enum AssetType {
        PAYROLL,
        TRUST,
        ESCROW,
        CROWDFUND,
        PERSONAL,
        CONTRACT,
        CUSTOM
    }

    struct Audit {
        address auditor;
        string auditReport;
    }

    struct Asset {
        uint256 fundiTokenId;
        address assetAddress;
        address fundiProtocol;
        string contractUri;
    }

    error NotFundi();
    error NotOwner();
    error AlreadyCreated();
    error NotFactoryOwner();

    address public immutable i_fundiProtocol;
    uint256 public i_fundiTokenId;
    address public immutable creator;
    address private immutable i_sourceContractAddress;
    string public s_contractURI;
    uint256 public s_assetCounter;
    uint256 public s_publicAudits;
    bool public isFundiFactory;
    mapping(uint256 => Audit) private s_auditInfo;
    mapping(uint256 => Asset) internal s_assetInfo;

    mapping(uint256 => Asset) public s_assets;
    uint256 public numberOfAssets = 0;

    function _isFundiProtocol() private view {
        if (_msgSender() != i_fundiProtocol) {
            revert NotFundi();
        }
    }

    modifier isFundiProtocol() {
        _isFundiProtocol();
        _;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    modifier assetMintable(uint256 tokenId) {
        _assetMintable(tokenId);
        _;
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
        address factoryOwner = IERC721(i_fundiProtocol).ownerOf(i_fundiTokenId);
        if (_msgSender() != factoryOwner) {
            revert NotFactoryOwner();
        }
    }

    function _assetMintable(uint256 fundiTokenId) internal view {
        if (_msgSender() != IERC721(i_fundiProtocol).ownerOf(fundiTokenId)) {
            revert NotOwner();
        }
        IFundiFactory.FundiAssetInfo memory fundiAsset = IFundiFactory(
            i_fundiProtocol
        ).getAssetInfo(fundiTokenId);
        if (s_assetInfo[fundiAsset.factoryTokenId].assetAddress != address(0)) {
            revert AlreadyCreated();
        }
        if (
            s_assetInfo[fundiAsset.factoryTokenId].fundiTokenId != fundiTokenId
        ) {
            revert NotFundi();
        }
    }

    constructor(address fundiProtocol, string memory _contractURI) {
        i_fundiProtocol = fundiProtocol;
        creator = msg.sender;
        s_assetCounter = 0;
        s_publicAudits = 0;
        s_contractURI = _contractURI;
        i_sourceContractAddress = address(this);
    }

    function mintFundiFactoryAsset(
        uint256 fundiTokenId //mint new asset here
    ) external isFundiProtocol nonReentrant returns (uint256) {
        return mintFactoryAsset(fundiTokenId);
    }

    function setContractURI(string memory _contractURI) public onlyOwner {
        s_contractURI = _contractURI; //have documentation here
    }

    function setFundiTokenId(
        uint256 _tokenId
    ) external isFundiProtocol returns (bool) {
        if (!isFundiFactory) {
            i_fundiTokenId = _tokenId;
            isFundiFactory = true;
            return true;
        }
        return false;
    }

    function contractURI() public view returns (string memory) {
        return s_contractURI;
    }

    function addContractAudit(string memory auditReport) public {
        s_auditInfo[s_publicAudits] = Audit(msg.sender, auditReport);
        s_publicAudits = s_publicAudits + 1;
    }

    function mintAsset(
        address fundiProtocol,
        uint256 fundiTokenId,
        string memory contractUri
    ) external virtual assetMintable(fundiTokenId) returns (address) {
        // ExampleFundiAsset newAsset = new ExampleFundiAsset(
        //     fundiProtocol,
        //     fundiTokenId,
        //     contractUri
        // );
        // IFundiFactory.FundiAssetInfo memory fundiAsset = IFundiFactory(
        //     fundiProtocol
        // ).getAssetInfo(fundiTokenId);
        // s_assetInfo[fundiAsset.factoryTokenId].assetAddress = address(newAsset);
        // Asset memory mintedAsset;
        // mintedAsset.fundiProtocol = fundiProtocol;
        // mintedAsset.assetAddress = address(newAsset);
        // mintedAsset.fundiTokenId = fundiTokenId;
        // mintedAsset.contractUri = contractUri;
        // s_assets[numberOfAssets] = mintedAsset;
        // numberOfAssets++;
        // return address(newAsset);
    }

    function mintFactoryAsset(uint256 fundiTokenId) private returns (uint256) {
        uint256 newTokenId = s_assetCounter;
        s_assetInfo[newTokenId] = Asset(
            fundiTokenId,
            address(0),
            i_fundiProtocol,
            ""
        );
        s_assetCounter += 1;
        return newTokenId;
    }

    function getAsset(
        uint256 factoryTokenId
    ) public view returns (uint256 fundiTokenId, address assetAddress) {
        return (
            s_assetInfo[factoryTokenId].fundiTokenId,
            s_assetInfo[factoryTokenId].assetAddress
        );
    }

    function getAssets(
        uint256 startIndex,
        uint256 endIndex
    ) external view returns (Asset[] memory) {
        Asset[] memory allAssets = new Asset[](numberOfAssets);

        for (uint256 i = startIndex; i < endIndex; i++) {
            Asset memory item = s_assets[i];
            allAssets[i] = item;
        }

        return allAssets;
    }

    function getAudit(
        uint256 auditId
    ) public view returns (address auditor, string memory report) {
        return (s_auditInfo[auditId].auditor, s_auditInfo[auditId].auditReport);
    }

    function getContractAddress() public view returns (address) {
        return i_sourceContractAddress;
    }

    function mintCount() public view returns (uint256) {
        return s_assetCounter;
    }
}
