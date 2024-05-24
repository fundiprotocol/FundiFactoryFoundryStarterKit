// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {MockFunctionsRouter} from "../mocks/MockFunctionsRouter.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";
import {MockCCIPRouter} from "@ccip-contracts/contracts-ccip/src/v0.8/ccip/test/mocks/MockRouter.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MockLinkToken} from "../mocks/MockLinkToken.sol";

contract HelperConfig {
    NetworkConfig public activeNetworkConfig;

    mapping(uint256 chainId => uint64 ccipChainSelector)
        public chainIdToCCIPChainSelector;

    struct NetworkConfig {
        address tslaPriceFeed;
        address usdcPriceFeed;
        address ethUsdPriceFeed;
        address functionsRouter;
        bytes32 donId;
        uint64 subId;
        address redemptionCoin;
        address linkToken;
        address ccipRouter;
        uint64 ccipChainSelector;
        uint64 secretVersion;
        uint8 secretSlot;
        // address fundiToken;
        // address fundiProtocol;
    }

    mapping(uint256 => NetworkConfig) public chainIdToNetworkConfig;

    // Mocks
    MockV3Aggregator public tslaFeedMock;
    MockV3Aggregator public ethUsdFeedMock;
    MockV3Aggregator public usdcFeedMock;
    MockUSDC public usdcMock;
    MockLinkToken public linkTokenMock;
    MockCCIPRouter public ccipRouterMock;

    MockFunctionsRouter public functionsRouterMock;

    // TSLA USD, ETH USD, and USDC USD both have 8 decimals
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;
    int256 public constant INITIAL_ANSWER_USD = 1e8;

    constructor() {
        chainIdToNetworkConfig[80_001] = getAmoyConfig();
        chainIdToNetworkConfig[31_337] = _setupAnvilConfig();

        chainIdToNetworkConfig[11155111] = getSepoliaConfig();
        chainIdToNetworkConfig[84532] = getBaseSepoliaConfig();

        activeNetworkConfig = chainIdToNetworkConfig[block.chainid];
    }

    function getAmoyConfig()
        internal
        pure
        returns (NetworkConfig memory config)
    {
        config = NetworkConfig({
            tslaPriceFeed: 0x1C2252aeeD50e0c9B64bDfF2735Ee3C932F5C408, // this is LINK / USD but it'll work fine
            usdcPriceFeed: 0x572dDec9087154dC5dfBB1546Bb62713147e0Ab0,
            ethUsdPriceFeed: 0x0715A7794a1dc8e42615F059dD6e406A6594651A,
            functionsRouter: 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C,
            donId: 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000,
            subId: 1396,
            redemptionCoin: 0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747,
            linkToken: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            ccipRouter: 0x1035CabC275068e0F4b745A29CEDf38E13aF41b1,
            ccipChainSelector: 12_532_609_583_862_916_517,
            secretVersion: 0, // fill in!
            secretSlot: 0
        });
        // minimumRedemptionAmount: 30e6 // Please see your brokerage for min redemption amounts
        // https://alpaca.markets/support/crypto-wallet-faq
    }

    function getSepoliaConfig()
        internal
        pure
        returns (NetworkConfig memory config)
    {
        config = NetworkConfig({
            tslaPriceFeed: 0xc59E3633BAAC79493d908e63626716e204A45EdF, // this is LINK / USD but it'll work fine
            usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            subId: 2274,
            redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            ccipRouter: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            ccipChainSelector: 16_015_286_601_757_825_753,
            secretVersion: 0, // fill in!
            secretSlot: 0 // fill in!
        });
        // minimumRedemptionAmount: 30e6 // Please see your brokerage for min redemption amounts
        // https://alpaca.markets/support/crypto-wallet-faq
    }

    function getBaseSepoliaConfig()
        internal
        pure
        returns (NetworkConfig memory config)
    {
        config = NetworkConfig({
            tslaPriceFeed: 0xc59E3633BAAC79493d908e63626716e204A45EdF, // this is LINK / USD but it'll work fine
            usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            subId: 2274,
            redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            linkToken: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410,
            ccipRouter: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93,
            ccipChainSelector: 10344971235874465080,
            secretVersion: 0, // fill in!
            secretSlot: 0 // fill in!
        });
        // minimumRedemptionAmount: 30e6 // Please see your brokerage for min redemption amounts
        // https://alpaca.markets/support/crypto-wallet-faq
    }

    function getAnvilEthConfig()
        internal
        view
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        anvilNetworkConfig = NetworkConfig({
            tslaPriceFeed: address(tslaFeedMock),
            usdcPriceFeed: address(tslaFeedMock),
            ethUsdPriceFeed: address(ethUsdFeedMock),
            functionsRouter: address(functionsRouterMock),
            donId: 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, // Dummy
            subId: 1, // Dummy non-zero
            redemptionCoin: address(usdcMock),
            linkToken: address(linkTokenMock),
            ccipRouter: address(ccipRouterMock),
            ccipChainSelector: 1, // This is a dummy non-zero value
            secretVersion: 0,
            secretSlot: 0
        });
        // minimumRedemptionAmount: 30e6 // Please see your brokerage for min redemption amounts
        // https://alpaca.markets/support/crypto-wallet-faq
    }

    function _setupAnvilConfig() internal returns (NetworkConfig memory) {
        usdcMock = new MockUSDC();
        tslaFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        ethUsdFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        usdcFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER_USD);
        functionsRouterMock = new MockFunctionsRouter();
        ccipRouterMock = new MockCCIPRouter();
        linkTokenMock = new MockLinkToken();
        return getAnvilEthConfig();
    }
}
