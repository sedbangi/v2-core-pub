// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

address constant PRANK_ADDRESS = 0x00000000000000000000000000746F6B656D616b;
address constant RANDOM = 0x86F65BF7298543655A913Edf463CcFC04691eF13;

// Same on all chains
address constant TELLOR_ORACLE = 0xD9157453E2668B2fc45b7A803D3FEF3642430cC0;

// Curves
address constant CURVE_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
address constant CURVE_META_REGISTRY_MAINNET = 0xF98B45FA17DE75FB1aD0e7aFD971b0ca00e379fC;

// Mainnet
address constant TOKE_MAINNET = 0x2e9d63788249371f1DFC918a52f8d799F4a38C94;
address constant WETH9_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant WETH_MAINNET = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant CRV_MAINNET = 0xD533a949740bb3306d119CC777fa900bA034cd52;
address constant CVX_MAINNET = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
address constant LDO_MAINNET = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;
address constant CONVEX_BOOSTER = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
address constant AURA_BOOSTER = 0xA57b8d98dAE62B26Ec3bcC4a365338157060B234;
address constant BAL_MAINNET = 0xba100000625a3754423978a60c9317c58a424e3D;
address constant BAL_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
address constant STETH_MAINNET = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
address constant RETH_MAINNET = 0xae78736Cd615f374D3085123A210448E74Fc6393;
address constant WSTETH_MAINNET = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
address constant CBETH_MAINNET = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
address constant SETH_MAINNET = 0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb;
address constant FRXETH_MAINNET = 0x5E8422345238F34275888049021821E8E08CAa1f;
address constant SFRXETH_MAINNET = 0xac3E018457B222d93114458476f3E3416Abbe38F;
address constant ZERO_EX_MAINNET = 0xDef1C0ded9bec7F1a1670819833240f027b25EfF;
address constant ONE_INCH_MAINNET = 0x1111111254EEB25477B68fb85Ed929f73A960582;
address constant USDC_MAINNET = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT_MAINNET = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
address constant FRAX_MAINNET = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
address constant DAI_MAINNET = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant SUSD_MAINNET = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
address constant UNI_ETH_MAINNET = 0xF1376bceF0f78459C0Ed0ba5ddce976F1ddF51F4;

// Mainnet Chainlink feed addresses
address constant RETH_CL_FEED_MAINNET = 0x536218f9E9Eb48863970252233c8F271f554C2d0;
address constant USDC_CL_FEED_MAINNET = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;
address constant USDT_CL_FEED_MAINNET = 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46;
address constant FRAX_CL_FEED_MAINNET = 0x14d04Fff8D21bd62987a5cE9ce543d2F1edF5D3E;
address constant DAI_CL_FEED_MAINNET = 0x773616E4d11A78F511299002da57A0a94577F1f4;
address constant SUSD_CL_FEED_MAINNET = 0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757;
address constant CRV_CL_FEED_MAINNET = 0x8a12Be339B0cD1829b91Adc01977caa5E9ac121e;
address constant CVX_CL_FEED_MAINNET = 0xC9CbF687f43176B302F03f5e58470b77D07c61c6;
address constant ETH_CL_FEED_MAINNET = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
address constant CBETH_CL_FEED_MAINNET = 0xF017fcB346A1885194689bA23Eff2fE6fA5C483b;
address constant STETH_CL_FEED_MAINNET = 0x86392dC19c0b719886221c78AB11eb8Cf5c52812;
address constant LDO_CL_FEED_MAINNET = 0x4e844125952D32AcdF339BE976c98E22F6F318dB;

// Lp tokens mainnet
address constant WSETH_WETH_BAL_POOL = 0x32296969Ef14EB0c6d29669C550D4a0449130230;
address constant RETH_WETH_BAL_POOL = 0x1E19CF2D73a72Ef1332C882F20534B6519Be0276;
address constant CBETH_WSTETH_BAL_POOL = 0x9c6d47Ff73e0F5E51BE5FD53236e3F595C5793F2;
address constant FRAX_CURVE_METAPOOL_LP = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
address constant THREE_CURVE_POOL_MAINNET_LP = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
address constant STETH_WETH_CURVE_POOL_LP = 0x828b154032950C8ff7CF8085D841723Db2696056;
address constant SETH_WETH_CURVE_POOL_LP = 0xA3D87FffcE63B53E0d54fAa1cc983B7eB0b74A9c;
address constant RETH_WSTETH_CURVE_POOL_LP = 0x447Ddd4960d9fdBF6af9a790560d0AF76795CB08;
address constant ETH_FRXETH_CURVE_POOL_LP = 0xf43211935C781D5ca1a41d2041F397B8A7366C7A;
address constant CRV_ETH_CURVE_V2_LP = 0xEd4064f376cB8d68F770FB1Ff088a3d0F3FF5c4d;
address constant CVX_ETH_CURVE_V2_LP = 0x3A283D9c08E8b55966afb64C515f5143cf907611;
address constant LDO_ETH_CURVE_V2_LP = 0xb79565c01b7Ae53618d9B847b9443aAf4f9011e7;
address constant WSETH_RETH_SFRXETH_BAL_POOL = 0x5aEe1e99fE86960377DE9f88689616916D5DcaBe;

// Curve pool addresses mainnet
address constant FRAX_CURVE_METAPOOL = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
address constant THREE_CURVE_MAINNET = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
address constant STETH_WETH_CURVE_POOL = 0x828b154032950C8ff7CF8085D841723Db2696056;
address constant STETH_ETH_CURVE_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant SETH_WETH_CURVE_POOL = 0xc5424B857f758E906013F3555Dad202e4bdB4567;
address constant RETH_WSTETH_CURVE_POOL = 0x447Ddd4960d9fdBF6af9a790560d0AF76795CB08;
address constant ETH_FRXETH_CURVE_POOL = 0xa1F8A6807c402E4A15ef4EBa36528A3FED24E577;
address constant CRV_ETH_CURVE_V2_POOL = 0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511;
address constant CVX_ETH_CURVE_V2_POOL = 0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
address constant LDO_ETH_CURVE_V2_POOL = 0x9409280DC1e6D33AB7A8C6EC03e5763FB61772B5;
address constant ST_ETH_CURVE_LP_TOKEN_MAINNET = 0x06325440D014e39736583c165C2963BA99fAf14E;
address constant UNI_WETH_POOL = 0xbFCe47224B4A938865E3e2727DC34E0fAA5b1D82;

// Arbitrum
address constant GRAIL_ARBITRUM = 0x3d9907F9a368ad0a51Be60f7Da3b97cf940982D8;
address constant CRV_ARBITRUM = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;
address constant CVX_ARBITRUM = 0xb952A807345991BD529FDded05009F5e80Fe8F45;
address constant LDO_ARBITRUM = 0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60;
address constant XGRAIL_ARBITRUM = 0x3CAaE25Ee616f2C8E13C74dA0813402eae3F496b;
address constant WSTETH_ARBITRUM = 0x5979D7b546E38E414F7E9822514be443A4800529;
address constant WETH_ARBITRUM = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
address constant USDC_ARBITRUM = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
address constant USDT_ARBITRUM = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
address constant WETH9_ARBITRUM = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

// Arbitrum Chainlink feed addresses
address constant USDC_CL_FEED_ARBITRUM = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
address constant USDT_CL_FEED_ARBITRUM = 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7;
address constant ETH_CL_FEED_ARBITRUM = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

// Lp tokens Arbitrum
address constant USDC_WETH_CAMELOT_POOL = 0x84652bb2539513BAf36e225c930Fdd8eaa63CE27;
address constant USDC_USDT_CAMELOT_POOL = 0x1C31fB3359357f6436565cCb3E982Bc6Bf4189ae;

// Optimism
address constant WETH9_OPTIMISM = 0x4200000000000000000000000000000000000006;
address constant USDC_OPTIMISM = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
address constant SUSDC_OPTIMISM = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
address constant VELO_OPTIMISM = 0x3c8B650257cFb5f272f799F5e2b4e65093a11a05;
address constant OP_OPTIMISM = 0x4200000000000000000000000000000000000042;
address constant OPTI_DOGE_OPTIMISM = 0x139283255069Ea5deeF6170699AAEF7139526f1f;
address constant WSTETH_OPTIMISM = 0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb;
address constant USDT_OPTIMISM = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
address constant SONNE_OPTIMISM = 0x1DB2466d9F5e10D7090E7152B68d62703a2245F0;
address constant RETH_OPTIMISM = 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D;
address constant SETH_OPTIMISM = 0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49;
address constant FRXETH_OPTIMISM = 0x6806411765Af15Bddd26f8f544A34cC40cb9838B;
address constant BEETHOVENX_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
address constant ROCKET_ETH_OVM_ORACLE = 0x1a8F81c256aee9C640e14bB0453ce247ea0DFE6F;

// Optimism Chainlink feed addresses
address constant SUSD_CL_FEED_OPTIMISM = 0x7f99817d87baD03ea21E05112Ca799d715730efe;
address constant USDC_CL_FEED_OPTIMISM = 0x16a9FA2FDa030272Ce99B29CF780dFA30361E0f3;
address constant WSTETH_CL_FEED_OPTIMISM = 0x698B585CbC4407e2D54aa898B2600B53C68958f7;
address constant ETH_CL_FEED_OPTIMISM = 0x13e3Ee699D1909E989722E753853AE30b17e08c5;

// Lp tokens Optimism
address constant RETH_WETH_BEETHOVEN_POOL = 0x4Fd63966879300caFafBB35D157dC5229278Ed23;
address constant WSTETH_USDC_BEETHOVEN_POOL = 0x899F737750db562b88c1E412eE1902980D3a4844;
address constant WETH_RETH_VELODROME_POOL = 0x69F795e2d9249021798645d784229e5bec2a5a25;
address constant USDC_SUSD_VELODROME_POOL = 0x93FC04cd6d108588Ecd844C7D60f46635037b5A3;
