// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../mocks/Fundi/FundiToken.sol";
import "../mocks/Fundi/FundiAssetFactoryProtocol.sol";
import "../src/Factories/ExampleFundiFactory.sol";
import "../src/Interfaces/IFundiProtocol.sol";
import "../src/Interfaces/IFundiAsset.sol";
import {LocalDeployFundiMock} from "../script/LocalDeployFundiMock.s.sol";

contract FundiFactoryTest is Test {
    FundiToken public fundiToken;
    // FactoryGovernor public factoryGovernor;
    // FactoryTimelock public factoryTimelock; if you want to test Fundi verification and flag functions
    FundiAssetFactoryProtocol public fundiProtocol;
    ExampleFundiFactory public fundiFactory;
    ExampleFundiFactory exampleFactory;
    address deployer;
    address developer = address(0x1);
    address businessUser = address(0x2);
    address hacker = address(0x3);

    error NotAuthorizedMustBeMinterOwner(address owner);
    error AlreadyAdded();

    function setUp() public {
        //<<deploy Fundi Mock and Give users tokens
        LocalDeployFundiMock deployment = new LocalDeployFundiMock();
        (fundiToken, fundiProtocol) = deployment.run();

        deployer = fundiToken.owner();

        vm.startPrank(deployer);
        fundiToken.transfer(developer, 100000000000000000000);
        fundiToken.transfer(businessUser, 100000000000000000000);
        fundiToken.transfer(address(this), fundiToken.balanceOf(deployer));
        fundiToken.renounceOwnership();
        vm.stopPrank();
        //>>deploy Fundi Mock and Give users tokens

        vm.startPrank(developer);
        exampleFactory = new ExampleFundiFactory(address(fundiProtocol));
        vm.stopPrank();
    }

    function test_add_factory_without_fee() public {
        vm.startPrank(hacker);
        vm.expectRevert(
            abi.encodeWithSelector(
                NotAuthorizedMustBeMinterOwner.selector,
                exampleFactory.creator()
            )
        );
        fundiProtocol.mintFactoryKey(
            address(exampleFactory),
            IFundiProtocol.AssetType.CROWDFUND,
            "Hacker example",
            address(fundiToken),
            0
        );
        vm.stopPrank();
        vm.startPrank(developer);

        fundiToken.approve(
            address(fundiProtocol),
            fundiProtocol.s_assetFactoryFee()
        );
        fundiProtocol.mintFactoryKey(
            address(exampleFactory), //factory address
            IFundiProtocol.AssetType.CUSTOM, //set type of asset your factory mints
            "FactoryContractURI", //contractURI with more info
            address(fundiToken), //set erc20 for your factory
            0 //set erc20 fee for your factory
        );
        vm.stopPrank();

        FundiAssetFactoryProtocol.AssetFactory memory factory = fundiProtocol
            .getFactoryInfo(address(exampleFactory));
        assertEq(address(exampleFactory), factory.contractAddress);
        assertEq(0, factory.factoryNum);
        assertEq(address(fundiToken), factory.tokenAddress);
        assertEq(0, factory.tokenMintFee);
        assertEq(true, factory.active);
        assertEq(false, factory.flagged);
        assertEq("", factory.flagReason);
        assertEq(false, factory.verified);
        assertEq(0, factory.mintCount);
    }

    function test_mint_asset_without_fee() public returns (uint256) {
        test_add_factory_without_fee();
        vm.startPrank(businessUser);
        FundiAssetFactoryProtocol.AssetFactory memory factory = fundiProtocol
            .getFactoryInfo(address(exampleFactory));
        fundiToken.approve(
            address(fundiProtocol),
            fundiProtocol.s_fundiMintFee()
        );
        uint256 mintCountBefore = factory.mintCount;
        uint256 tokenId = fundiProtocol.mintAssetKey(
            "First Contract",
            address(exampleFactory),
            true,
            businessUser
        );
        factory = fundiProtocol.getFactoryInfo(address(exampleFactory));
        assertEq(mintCountBefore + 1, factory.mintCount);
        assertEq(businessUser, fundiProtocol.ownerOf(tokenId));
        exampleFactory.mintAsset(
            address(fundiProtocol),
            tokenId,
            "CustomTokenUri"
        );
        vm.stopPrank();
        return tokenId;
    }
}
