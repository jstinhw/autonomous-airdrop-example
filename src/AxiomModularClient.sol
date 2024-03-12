// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "@axiom-crypto/v2-periphery/interfaces/client/IAxiomV2Client.sol";
import { AxiomModule } from "./modules/AxiomModule.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { IAxiomModuleValidator } from "./interfaces/IAxiomModuleValidator.sol";
import { IAxiomModuleExecutor } from "./interfaces/IAxiomModuleExecutor.sol";

struct Module {
    address validator;
    address executor;
}

contract AxiomModularClient is IAxiomV2Client, Ownable {
    /// @dev address of AxiomV2Query
    address public immutable axiomV2QueryAddress;

    /// @dev mapping of query schema to module
    mapping(bytes32 => Module) public modules;

    /// @notice Whether the callback is made from an on-chain or off-chain query
    /// @param OnChain The callback is made from an on-chain query
    /// @param OffChain The callback is made from an off-chain query
    enum AxiomCallbackType {
        OnChain,
        OffChain
    }

    /// @notice Construct a new AxiomV2Client contract.
    /// @param  _axiomV2QueryAddress The address of the AxiomV2Query contract.
    constructor(address _axiomV2QueryAddress) Ownable() {
        if (_axiomV2QueryAddress == address(0)) {
            revert AxiomV2QueryAddressIsZero();
        }
        axiomV2QueryAddress = _axiomV2QueryAddress;
    }

    function installModule(
        bytes32 querySchema,
        address validator,
        address executor,
        bytes calldata validatorData,
        bytes calldata executorData
    ) external onlyOwner {
        modules[querySchema] = Module(validator, executor);
        IAxiomModuleValidator(validator).onInstall(validatorData);
        IAxiomModuleExecutor(executor).onInstall(executorData);
    }

    function uninstallModule(bytes32 querySchema) external onlyOwner {
        delete modules[querySchema];
    }

    /// @inheritdoc IAxiomV2Client
    function axiomV2Callback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external {
        if (msg.sender != axiomV2QueryAddress) {
            revert CallerMustBeAxiomV2Query();
        }
        emit AxiomV2Call(sourceChainId, caller, querySchema, queryId);
        Module memory module = modules[querySchema];

        IAxiomModuleValidator(module.validator).axiomV2Callback(
            sourceChainId, caller, querySchema, queryId, axiomResults, extraData
        );
        IAxiomModuleExecutor(module.executor).axiomV2CallbackExecution(
            sourceChainId, caller, querySchema, queryId, axiomResults, extraData
        );
    }

    /// @inheritdoc IAxiomV2Client
    function axiomV2OffchainCallback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external {
        if (msg.sender != axiomV2QueryAddress) {
            revert CallerMustBeAxiomV2Query();
        }
        emit AxiomV2OffchainCall(sourceChainId, caller, querySchema, queryId);
        Module memory module = modules[querySchema];

        IAxiomModuleValidator(module.validator).axiomV2Callback(
            sourceChainId, caller, querySchema, queryId, axiomResults, extraData
        );
        IAxiomModuleExecutor(module.executor).axiomV2CallbackExecution(
            sourceChainId, caller, querySchema, queryId, axiomResults, extraData
        );
    }
}
