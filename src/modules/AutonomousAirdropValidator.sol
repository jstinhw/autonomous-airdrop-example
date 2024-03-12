// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { AxiomModule } from "./AxiomModule.sol";
import { IAxiomModuleValidator } from "../interfaces/IAxiomModuleValidator.sol";

struct AutonomousAirdropStorage {
    address pool;
    uint32 minBlockNumber;
}

contract AutonomousAirdropValidator is AxiomModule, IAxiomModuleValidator, Ownable {
    event ClaimAirdrop(address indexed user, uint256 indexed queryId, uint256 numTokens, bytes32[] axiomResults);
    event AxiomCallbackQuerySchemaUpdated(bytes32 axiomCallbackQuerySchema);
    event AirdropUpdated(address client, address pool, uint32 minBlockNumber);

    uint64 public callbackSourceChainId;
    bytes32 public axiomCallbackQuerySchema;
    mapping(address => bool) public querySubmitted;
    mapping(address => AutonomousAirdropStorage) public airdrops;

    constructor(address _axiomV2QueryAddress, uint64 _callbackSourceChainId, bytes32 _axiomCallbackQuerySchema)
        AxiomModule(_axiomV2QueryAddress)
        Ownable()
    {
        callbackSourceChainId = _callbackSourceChainId;
        axiomCallbackQuerySchema = _axiomCallbackQuerySchema;
    }

    function updateCallbackQuerySchema(bytes32 _axiomCallbackQuerySchema) public onlyOwner {
        axiomCallbackQuerySchema = _axiomCallbackQuerySchema;
        emit AxiomCallbackQuerySchemaUpdated(_axiomCallbackQuerySchema);
    }

    function onInstall(bytes calldata data) public {
        (address pool, uint32 minBlockNumber) = abi.decode(data, (address, uint32));
        airdrops[msg.sender] = AutonomousAirdropStorage(pool, minBlockNumber);
        emit AirdropUpdated(msg.sender, pool, minBlockNumber);
    }

    function _axiomV2Callback(
        uint64, /* sourceChainId */
        address callerAddr,
        bytes32, /* querySchema */
        uint256, /* queryId */
        bytes32[] calldata axiomResults,
        bytes calldata /* extraData */
    ) internal virtual override {
        // Parse results
        address userEventAddress = address(uint160(uint256(axiomResults[0])));
        uint32 blockNumber = uint32(uint256(axiomResults[1]));
        address uniV3PoolUniWethAddr = address(uint160(uint256(axiomResults[2])));

        AutonomousAirdropStorage memory airdrop = airdrops[msg.sender];

        // Validate the results
        require(userEventAddress == callerAddr, "Autonomous Airdrop: Invalid user address for event");
        require(
            blockNumber >= airdrop.minBlockNumber,
            "Autonomous Airdrop: Block number for transaction receipt must be 4000000 or greater"
        );
        require(
            uniV3PoolUniWethAddr == airdrop.pool,
            "Autonomous Airdrop: Address that emitted `Swap` event is not the UniV3 UNI-WETH pool address"
        );
    }

    function _validateAxiomV2Call(
        AxiomCallbackType, /* callbackType */
        uint64 sourceChainId,
        address, /* caller  */
        bytes32 querySchema,
        uint256, /* queryId */
        bytes calldata /* extraData */
    ) internal virtual override {
        require(sourceChainId == callbackSourceChainId, "AutonomousAirdrop: sourceChainId mismatch");
        require(querySchema == axiomCallbackQuerySchema, "AutonomousAirdrop: querySchema mismatch");
    }
}
