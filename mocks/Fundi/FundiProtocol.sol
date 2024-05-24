//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

abstract contract FundiProtocol is Context, ReentrancyGuard {
    error NotProtocolOwner(address owner);
    error NotValidator();
    struct Audit {
        address auditor;
        string auditReport;
    }

    address public i_fundiValidator;
    IERC20 public immutable i_fundiToken;

    uint256 public i_protocolTokenId; //can only be updated once

    address public premintOwner;
    string public s_contractURI;
    bool public protocolMinted;
    uint256 public s_publicAudits;
    address public immutable i_fundiProtocolGovernor;

    mapping(uint256 => Audit) private s_auditInfo;

    function _onlyDAO() private view {
        require(_msgSender() == i_fundiProtocolGovernor, "Only DAO");
    }

    modifier onlyDAO() {
        _onlyDAO();
        _;
    }

    modifier onlyOwner() {
        _checkProtocolOwner();
        _;
    }

    function _checkProtocolOwner() internal view {
        if (_msgSender() != owner()) {
            revert NotProtocolOwner(owner());
        }
    }

    modifier isFundiValidator() {
        _isFundiValidator();
        _;
    }

    function _isFundiValidator() private view {
        if (_msgSender() != i_fundiValidator) {
            revert NotValidator();
        }
    }

    function owner() public view returns (address) {
        if (i_protocolTokenId == 0) {
            return premintOwner;
        } else {
            return IERC721(i_fundiValidator).ownerOf(i_protocolTokenId);
        }
    }

    constructor(
        address fundiToken,
        address fundiValidator,
        string memory _contractUri,
        address _owner,
        address fundiProtocolTimelock
    ) {
        i_fundiToken = IERC20(fundiToken);
        i_fundiProtocolGovernor = fundiProtocolTimelock;
        i_fundiValidator = fundiValidator;
        s_contractURI = _contractUri;
        premintOwner = _owner;
    }

    function setContractURI(string memory _contractURI) external onlyOwner {
        s_contractURI = _contractURI; //have documentation here
    }

    function setProtocolTokenID(
        uint256 _tokenId
    ) external isFundiValidator returns (bool) {
        if (!protocolMinted) {
            i_protocolTokenId = _tokenId;
            protocolMinted = true;
            return true;
        }
        return false;
    }

    function addContractAudit(string memory auditReport) external {
        uint256 auditId = s_publicAudits + 1;
        s_auditInfo[auditId] = Audit(msg.sender, auditReport);
        s_publicAudits = auditId;
    }

    //view functions

    function contractURI() public view returns (string memory) {
        return s_contractURI;
    }

    function getAudit(
        uint256 auditId
    ) public view returns (address auditor, string memory report) {
        return (s_auditInfo[auditId].auditor, s_auditInfo[auditId].auditReport);
    }

    function getFundiID() public view returns (address, uint256) {
        return (i_fundiValidator, i_protocolTokenId);
    }

    //protocol owner functions

    function setValidator(address validatorAddress) external onlyOwner {
        if (!protocolMinted) {
            i_fundiValidator = validatorAddress;
        }
    }

    function transferOwnership(
        address newOwner
    ) public nonReentrant onlyOwner returns (bool) {
        if (i_protocolTokenId == 0) {
            premintOwner = newOwner;
            return true;
        } else {
            if (
                IERC721(i_fundiValidator).getApproved(i_protocolTokenId) !=
                address(this)
            ) {
                revert("Must approve protocol address for transfer");
            } else {
                IERC721(i_fundiValidator).safeTransferFrom(
                    owner(),
                    newOwner,
                    i_protocolTokenId
                );
                return true;
            }
        }
    }
}
