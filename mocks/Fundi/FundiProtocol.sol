// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title FundiProtocol
 * @dev Copyright (c) 2025 Fundi Labs LLC All rights reserved.
 *
 * This source code is proprietary and confidential.
 * Unauthorized copying, modification, distribution, or use of this file,
 * via any medium, is strictly prohibited.
 *
 * For licensing inquiries, visit https://fundilabs.io
 *
 * */

/**
 * @title FundiProtocol
 * @dev Abstract contract that defines the base functionality for protocols in the Fundi ecosystem
 * Protocols can be registered with a validator, receive audits, and have their ownership managed
 */
abstract contract FundiProtocol is Context, ReentrancyGuard {
    // ===============================================
    // ============== Type Definitions ==============
    // ===============================================

    /**
     * @dev Structure to store audit information
     */
    struct Audit {
        address auditor; // Address of the auditor
        string auditReport; // IPFS hash or URI to the audit report
    }

    // ===============================================
    // ================= Errors =====================
    // ===============================================

    error NotProtocolOwner(address owner); // Caller is not the protocol owner
    error NotValidator(); // Caller is not the validator

    // ===============================================
    // ================ State Variables =============
    // ===============================================

    // Immutable state variables
    IERC20 public immutable i_fundiToken; // Token used for payments
    address public immutable i_fundiProtocolGovernor; // Address of the governance contract (DAO)

    // Mutable state variables
    address public i_fundiValidator; // Address of the validator contract
    uint256 public i_protocolTokenId; // Token ID in the validator contract (can only be updated once)
    address public premintOwner; // Owner before protocol token is minted
    string public s_contractURI; // URI for contract metadata
    bool public protocolMinted; // Whether protocol token has been minted
    uint256 public s_publicAudits; // Count of public audits

    // Mappings
    mapping(uint256 => Audit) private s_auditInfo; // Audit info by audit ID

    // ===============================================
    // ================ Modifiers ===================
    // ===============================================

    /**
     * @dev Ensures caller is the DAO governor
     */
    modifier onlyDAO() {
        _onlyDAO();
        _;
    }

    /**
     * @dev Ensures caller is the owner of this protocol
     */
    modifier onlyOwner() {
        _checkProtocolOwner();
        _;
    }

    /**
     * @dev Ensures caller is the validator contract
     */
    modifier isFundiValidator() {
        _isFundiValidator();
        _;
    }

    // ===============================================
    // ============== Constructor ===================
    // ===============================================

    /**
     * @dev Constructor for the FundiProtocol contract
     * @param fundiToken Address of the Fundi token contract
     * @param fundiValidator Address of the validator contract
     * @param fundiProtocolTimelock Address of the timelock (DAO) contract
     * @param _contractUri URI for contract metadata
     */
    constructor(
        address fundiToken,
        address fundiValidator,
        address fundiProtocolTimelock,
        string memory _contractUri
    ) {
        i_fundiToken = IERC20(fundiToken); // Fundi token address
        i_fundiProtocolGovernor = fundiProtocolTimelock;
        i_fundiValidator = fundiValidator; // Validator planning to mint
        s_contractURI = _contractUri;
        premintOwner = msg.sender;
    }

    // ===============================================
    // ============ Internal Functions ==============
    // ===============================================

    /**
     * @dev Internal function to verify caller is the DAO
     */
    function _onlyDAO() private view {
        require(_msgSender() == i_fundiProtocolGovernor, "Only DAO");
    }

    /**
     * @dev Internal function to verify caller is the protocol owner
     */
    function _checkProtocolOwner() internal view {
        if (_msgSender() != owner()) {
            revert NotProtocolOwner(owner());
        }
    }

    /**
     * @dev Internal function to verify caller is the validator
     */
    function _isFundiValidator() private view {
        if (_msgSender() != i_fundiValidator) {
            revert NotValidator();
        }
    }

    // ===============================================
    // ============= External Functions =============
    // ===============================================

    /**
     * @dev Sets the contract URI for metadata (owner only)
     * @param _contractURI New contract URI
     */
    function setContractURI(string memory _contractURI) external onlyOwner {
        s_contractURI = _contractURI; // Have documentation here
    }

    /**
     * @dev Sets the protocol token ID (validator only)
     * Can only be called once
     * @param _tokenId Token ID to set
     * @return Success indicator
     */
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

    /**
     * @dev Adds a public audit report
     * Anyone can add an audit report
     * @param auditReport URI or IPFS hash of the audit report
     */
    function addContractAudit(string memory auditReport) external {
        uint256 auditId = s_publicAudits + 1;
        s_auditInfo[auditId] = Audit(msg.sender, auditReport);
        s_publicAudits = auditId;
    }

    /**
     * @dev Sets the validator address (owner only)
     * Can only be called before the protocol is minted
     * @param validatorAddress Address of the new validator
     */
    function setValidator(address validatorAddress) external onlyOwner {
        if (!protocolMinted) {
            i_fundiValidator = validatorAddress;
        }
    }

    /**
     * @dev Transfers ownership of the protocol (owner only)
     * @param newOwner Address of the new owner
     * @return Success indicator
     */
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

    // ===============================================
    // ============= View Functions =================
    // ===============================================

    /**
     * @dev Returns the owner of this protocol
     * @return Address of the owner
     */
    function owner() public view returns (address) {
        if (i_protocolTokenId == 0) {
            return premintOwner;
        } else {
            return IERC721(i_fundiValidator).ownerOf(i_protocolTokenId);
        }
    }

    /**
     * @dev Returns the contract URI
     * @return Contract URI
     */
    function contractURI() public view returns (string memory) {
        return s_contractURI;
    }

    /**
     * @dev Returns information about an audit
     * @param auditId ID of the audit
     * @return auditor Address of the auditor
     * @return report Audit report URI or IPFS hash
     */
    function getAudit(
        uint256 auditId
    ) public view returns (address auditor, string memory report) {
        return (s_auditInfo[auditId].auditor, s_auditInfo[auditId].auditReport);
    }

    /**
     * @dev Returns the Fundi validator address and token ID
     * @return Validator address and token ID
     */
    function getFundiID() public view returns (address, uint256) {
        return (i_fundiValidator, i_protocolTokenId);
    }
}
