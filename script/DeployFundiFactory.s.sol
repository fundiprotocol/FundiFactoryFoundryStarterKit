// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Factories/ExampleFundiFactory.sol";
import {FundiToken} from "../mocks/Fundi/FundiToken.sol";
import "../src/Interfaces/IFundiProtocol.sol";
import "../mocks/Fundi/FundiAssetFactoryProtocol.sol";

contract DeployFundiFactory is Script {
    FundiToken public fundiToken =
        FundiToken(0x0d8D726d0614FD993fc78946ae9d54Fd4DA6D2FE); //Base
    FundiAssetFactoryProtocol public fundiProtocol =
        FundiAssetFactoryProtocol(0xd38Ec3705e7DC81248a07531A29C0ad66eAE3cd3);

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
