pragma solidity ^0.8.13;

//import {HelperConfig} from "./HelperConfig.s.sol";
import "forge-std/Script.sol";
import {FundiToken} from "../mocks/Fundi/FundiToken.sol";
import {FundiAssetFactoryProtocol} from "../mocks/Fundi/FundiAssetFactoryProtocol.sol";
import {FundiAssetProtocolMetadata} from "../mocks/Fundi/FundiAssetProtocolMetadata.sol";
import {FactoryGovernor} from "../src/Governance/FactoryGovernor.sol";
import {FactoryTimelock} from "../src/Governance/FactoryTimelock.sol";
import "../src/Governance/FactoryTimelock.sol";

contract LocalDeployFundiMock is Script {
    FundiToken public fundiToken;
    FactoryTimelock public factoryTimelock;
    FactoryGovernor public factoryGovernor;
    uint256 FACTORY_VOTING_DELAY = 3600; //1 hour
    uint256 FACTORY_VOTING_PERIOD = 272; //1 hour
    address[] public blankAddresses;

    function run() public returns (FundiToken, FundiAssetFactoryProtocol) {
        vm.startBroadcast();
        fundiToken = new FundiToken(tx.origin);

        factoryTimelock = new FactoryTimelock(
            FACTORY_VOTING_DELAY, //3 days
            blankAddresses,
            blankAddresses,
            tx.origin //temp admin
        );
        factoryGovernor = new FactoryGovernor(fundiToken, factoryTimelock);

        //set up governance
        //set up roles
        bytes32 proposerRole = factoryTimelock.PROPOSER_ROLE();
        bytes32 executorRole = factoryTimelock.EXECUTOR_ROLE();
        bytes32 adminRole = factoryTimelock.TIMELOCK_ADMIN_ROLE();

        factoryTimelock.grantRole(proposerRole, address(factoryGovernor));
        factoryTimelock.grantRole(
            executorRole,
            0x0000000000000000000000000000000000000000
        ); //anyone can execute now
        factoryTimelock.revokeRole(adminRole, tx.origin);

        FundiAssetProtocolMetadata protocolMetadata = new FundiAssetProtocolMetadata();

        FundiAssetFactoryProtocol fundiProtocol = new FundiAssetFactoryProtocol(
            address(fundiToken),
            address(factoryTimelock),
            address(0),
            "Fundi Asset Protocol Mock",
            address(protocolMetadata),
            address(tx.origin)
        );

        vm.stopBroadcast();
        // console.log("Protocol deployed at: ", address(fundiProtocol));

        return (fundiToken, fundiProtocol);
    }
}
