//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import {ExampleFundiAsset} from "../Assets/ExampleFundiAsset.sol"; //contract to tokenize
import "./FundiFactory.sol";

contract ExampleFundiFactory is FundiFactory {
    constructor(
        address fundiProtocol
    ) FundiFactory(fundiProtocol, "FactoryContractURI") {}

    //REQUIRED
    //mint tokenized contract
    function mintAsset(
        address fundiProtocol,
        uint256 fundiTokenId,
        string memory contractUri
    ) external override assetMintable(fundiTokenId) returns (address) {
        ExampleFundiAsset newAsset = new ExampleFundiAsset(
            fundiProtocol,
            fundiTokenId,
            contractUri
        );
        IFundiFactory.FundiAssetInfo memory fundiAsset = IFundiFactory(
            fundiProtocol
        ).getAssetInfo(fundiTokenId);
        s_assetInfo[fundiAsset.factoryTokenId].assetAddress = address(newAsset);
        Asset memory mintedAsset;
        mintedAsset.fundiProtocol = fundiProtocol;
        mintedAsset.assetAddress = address(newAsset);
        mintedAsset.fundiTokenId = fundiTokenId;
        mintedAsset.contractUri = contractUri;
        s_assets[numberOfAssets] = mintedAsset;
        numberOfAssets++;
        return address(newAsset);
    }
}
