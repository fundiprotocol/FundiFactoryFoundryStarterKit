// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Factories/ExampleFundiFactory.sol";
import {FundiToken} from "../mocks/Fundi/FundiToken.sol";
import "../src/Interfaces/IFundiProtocol.sol";
import "../mocks/Fundi/FundiAssetFactoryProtocol.sol";

contract DeployFundiFactory is Script {
    FundiToken public fundiToken =
        FundiToken(0xA2280e562FC1AFaba579b1c6640Fa526E90B4210); //Base Sepolia
    FundiAssetFactoryProtocol public fundiProtocol =
        FundiAssetFactoryProtocol(0xaA034135B32B827b77a2342e714bf12F57Ce81ed);

    function run()
        external
        returns (ExampleFundiFactory, FundiAssetFactoryProtocol)
    {
        uint256 deployerPrivateKey = vm.envUint("LOCAL_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ExampleFundiFactory exampleFactory = new ExampleFundiFactory(
            address(fundiProtocol)
        );
        console.log("Factory deployed at: ", address(exampleFactory));
        fundiToken.approve(
            address(fundiProtocol),
            fundiProtocol.s_assetFactoryFee()
        );
        fundiProtocol.mintFactoryKey(
            address(exampleFactory),
            IFundiProtocol.AssetType.CUSTOM,
            "FactoryContractURI",
            address(fundiToken),
            0
        );
        console.log(
            "Factory added to Fundi Protocol at: ",
            address(fundiProtocol)
        );
        vm.stopBroadcast();
        return (exampleFactory, fundiProtocol);
    }
}
