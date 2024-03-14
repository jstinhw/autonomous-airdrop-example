// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {AutonomousAirdropExecutor} from "../src/modules/AutonomousAirdropExecutor.sol"; 
import {AutonomousAirdropValidator} from "../src/modules/AutonomousAirdropValidator.sol";
import {AxiomModularClient} from "../src/AxiomModularClient.sol";
import {UselessToken} from "../src/UselessToken.sol";

contract AutonomousAirdropModuleScript is Script {
    address public constant AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR = 0x83c8c0B395850bA55c830451Cfaca4F2A667a983;
    bytes32 querySchema;

    function setUp() public {
        string memory artifact = vm.readFile("./app/axiom/data/compiled.json");
        querySchema = bytes32(vm.parseJson(artifact, ".querySchema"));
    }

    function run() public {
      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
      vm.startBroadcast(deployerPrivateKey);
      // deploy client, validator, executor
      new AxiomModularClient(AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR);
      new AutonomousAirdropValidator(AXIOM_V2_QUERY_MOCK_SEPOLIA_ADDR, 11155111, querySchema);
      AutonomousAirdropExecutor aaExecutor = new AutonomousAirdropExecutor();

      // deploy useless token
      new UselessToken(address(aaExecutor));

      vm.stopBroadcast();
    }

}