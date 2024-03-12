// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IAxiomModuleExecutor } from "../interfaces/IAxiomModuleExecutor.sol";

contract AutonomousAirdropExecutor is IAxiomModuleExecutor {
    event ClaimAirdrop(address indexed user, uint256 indexed queryId, uint256 numTokens, bytes32[] axiomResults);
    event ClaimAirdropError(address indexed user, string error);
    event AirdropTokenAddressUpdated(address client, address token);

    bytes32 public constant SWAP_EVENT_SCHEMA = 0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67;

    mapping(address => address) public tokens;
    mapping(address => mapping(address => bool)) public hasClaimed;

    function onInstall(bytes calldata data) public {
        (address token) = abi.decode(data, (address));
        tokens[msg.sender] = token;
        emit AirdropTokenAddressUpdated(msg.sender, token);
    }

    function axiomV2CallbackExecution(
        uint64, /* sourceChainId */
        address callerAddr,
        bytes32, /* querySchema */
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata /* extraData */
    ) public {
        require(!hasClaimed[msg.sender][callerAddr], "Autonomous Airdrop: User has already claimed this airdrop");

        // Transfer tokens to user
        hasClaimed[msg.sender][callerAddr] = true;
        address token = tokens[msg.sender];
        uint256 numTokens = 100 * 10 ** 18;
        IERC20(token).transfer(callerAddr, numTokens);

        emit ClaimAirdrop(callerAddr, queryId, numTokens, axiomResults);
    }
}
