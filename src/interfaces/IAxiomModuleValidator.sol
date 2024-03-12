// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "@axiom-crypto/v2-periphery/interfaces/client/IAxiomV2Client.sol";

interface IAxiomModuleValidator is IAxiomV2Client {
    /// @notice Perform moduel installation setup
    /// @param data The data to be used for setup
    function onInstall(bytes calldata data) external;
}
