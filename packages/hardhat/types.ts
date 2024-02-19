import { Noir } from '@noir-lang/noir_js';
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { CompiledCircuit, ProofData } from '@noir-lang/types';

export type Circuits = {
  main: CompiledCircuit;
  second: CompiledCircuit;
  recursive: CompiledCircuit;
};

export type BackendInstances = {
  main: BarretenbergBackend;
  second: BarretenbergBackend;
  recursive: BarretenbergBackend;
};

export type Noirs = {
  main: Noir;
  second: Noir;
  recursive: Noir;
};

export interface ProofArtifacts extends ProofData {
  proofAsFields: string[];
  vkAsFields: string[];
  vkHash: string;
}
