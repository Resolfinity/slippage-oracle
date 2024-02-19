// This file was autogenerated by hardhat-viem, do not edit it.
// prettier-ignore
// tslint:disable
// eslint-disable

import type { Address } from "viem";
import type { GetContractReturnType } from "@nomicfoundation/hardhat-viem/types";
import "@nomicfoundation/hardhat-viem/types";

export interface UltraVerificationKey$Type {
  "_format": "hh-sol-artifact-1",
  "contractName": "UltraVerificationKey",
  "sourceName": "noir/recursion/contract/recursion/plonk_vk.sol",
  "abi": [],
  "bytecode": "0x60566037600b82828239805160001a607314602a57634e487b7160e01b600052600060045260246000fd5b30600052607381538281f3fe73000000000000000000000000000000000000000030146080604052600080fdfea264697066735822122076706cef58e529685fe28febbc54e864004c7dd99686a8d394acfb58aec525ec64736f6c63430008120033",
  "deployedBytecode": "0x73000000000000000000000000000000000000000030146080604052600080fdfea264697066735822122076706cef58e529685fe28febbc54e864004c7dd99686a8d394acfb58aec525ec64736f6c63430008120033",
  "linkReferences": {},
  "deployedLinkReferences": {}
}

declare module "@nomicfoundation/hardhat-viem/types" {
  export function deployContract(
    contractName: "UltraVerificationKey",
    constructorArgs?: [],
    config?: DeployContractConfig
  ): Promise<GetContractReturnType<UltraVerificationKey$Type["abi"]>>;
  export function deployContract(
    contractName: "noir/recursion/contract/recursion/plonk_vk.sol:UltraVerificationKey",
    constructorArgs?: [],
    config?: DeployContractConfig
  ): Promise<GetContractReturnType<UltraVerificationKey$Type["abi"]>>;

  export function sendDeploymentTransaction(
    contractName: "UltraVerificationKey",
    constructorArgs?: [],
    config?: SendDeploymentTransactionConfig
  ): Promise<{
    contract: GetContractReturnType<UltraVerificationKey$Type["abi"]>;
    deploymentTransaction: GetTransactionReturnType;
  }>;
  export function sendDeploymentTransaction(
    contractName: "noir/recursion/contract/recursion/plonk_vk.sol:UltraVerificationKey",
    constructorArgs?: [],
    config?: SendDeploymentTransactionConfig
  ): Promise<{
    contract: GetContractReturnType<UltraVerificationKey$Type["abi"]>;
    deploymentTransaction: GetTransactionReturnType;
  }>;

  export function getContractAt(
    contractName: "UltraVerificationKey",
    address: Address,
    config?: GetContractAtConfig
  ): Promise<GetContractReturnType<UltraVerificationKey$Type["abi"]>>;
  export function getContractAt(
    contractName: "noir/recursion/contract/recursion/plonk_vk.sol:UltraVerificationKey",
    address: Address,
    config?: GetContractAtConfig
  ): Promise<GetContractReturnType<UltraVerificationKey$Type["abi"]>>;
}