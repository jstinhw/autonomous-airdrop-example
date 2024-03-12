// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAxiomModuleExecutor {
    /// @notice Perform moduel installation setup
    /// @param data The data to be used for setup
    function onInstall(bytes calldata data) external;

    /// @notice Callback function for AxiomV2Query
    /// @param sourceChainId The ID of the chain the query reads from.
    /// @param caller The address of the account that initiated the query.
    /// @param querySchema The schema of the query.
    /// @param queryId The ID of the query.
    /// @param axiomResults The results of the query.
    /// @param extraData The extra data of the query.
    function axiomV2CallbackExecution(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external;
}
