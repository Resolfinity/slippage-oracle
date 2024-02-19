import chai from 'chai';
const { expect } = chai;
import { Noir } from '@noir-lang/noir_js';
import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { BackendInstances, Circuits, Noirs } from '../types.js';
import hre from 'hardhat';
const { viem } = hre;
import { compile, createFileManager } from '@noir-lang/noir_wasm';
import { join, resolve } from 'path';
import { ProofData } from '@noir-lang/types';
import { bytesToHex } from 'viem';
import fs from 'fs';

async function getCircuit(name: string) {
  const basePath = resolve(join('../noir', name));
  const fm = createFileManager(basePath);
  const compiled = await compile(fm, basePath);
  if (!('program' in compiled)) {
    throw new Error('Compilation failed');
  }
  return compiled.program;
}

describe('It compiles noir program code, receiving circuit bytes and abi object.', () => {
  let circuits: Circuits;
  let backends: BackendInstances;
  let noirs: Noirs;

  const mainInput = { x: 1, y: 2 };
  const secondInput = { x: 5, y: 4 };

  before(async () => {
    circuits = {
      main: await getCircuit('main'),
      second: await getCircuit('second'),
      recursive: await getCircuit('recursion'),
    };
    backends = {
      main: new BarretenbergBackend(circuits.main, { threads: 8 }),
      second: new BarretenbergBackend(circuits.second, { threads: 8 }),
      recursive: new BarretenbergBackend(circuits.recursive, { threads: 8 }),
    };
    noirs = {
      main: new Noir(circuits.main, backends.main),
      second: new Noir(circuits.second, backends.second),
      recursive: new Noir(circuits.recursive, backends.recursive),
    };
  });

  after(async () => {
    await backends.main.destroy();
    await backends.second.destroy();
    await backends.recursive.destroy();
  });

  describe('Recursive flow', async () => {
    let recursiveInputs: any;
    let intermediateProof: ProofData;
    let secondRecursiveInputs: any;
    let secondIntermediateProof: ProofData;
    let finalProof: ProofData;

    describe('Proof generation', async () => {
      it('Should generate an main proof', async () => {
        const { witness } = await noirs.main.execute(mainInput);
        intermediateProof = await backends.main.generateIntermediateProof(witness);

        const { proof, publicInputs } = intermediateProof;
        expect(proof instanceof Uint8Array).to.be.true;

        const verified = await backends.main.verifyIntermediateProof({ proof, publicInputs });
        expect(verified).to.be.true;

        const numPublicInputs = 1;
        const { proofAsFields, vkAsFields, vkHash } =
          await backends.main.generateIntermediateProofArtifacts(
            { publicInputs, proof },
            numPublicInputs,
          );

        console.log('proofAsFields', proofAsFields);
        expect(vkAsFields).to.be.of.length(114);
        console.log('vkAsFields', vkAsFields);
        expect(vkHash).to.be.a('string');

        //ab7f5360ffb7

        recursiveInputs = {
          verification_key: vkAsFields,
          proof: proofAsFields,
          public_inputs: [mainInput.y],
          key_hash: vkHash,
        };

        fs.writeFileSync('recursiveInputs.json', JSON.stringify(recursiveInputs));
      });

      it('Should generate an second proof', async () => {
        const { witness } = await noirs.second.execute(secondInput);
        secondIntermediateProof = await backends.second.generateIntermediateProof(witness);

        const { proof, publicInputs } = secondIntermediateProof;
        expect(proof instanceof Uint8Array).to.be.true;

        const verified = await backends.second.verifyIntermediateProof({ proof, publicInputs });
        expect(verified).to.be.true;

        const numPublicInputs = 1;
        const { proofAsFields, vkAsFields, vkHash } =
          await backends.second.generateIntermediateProofArtifacts(
            { publicInputs, proof },
            numPublicInputs,
          );

        console.log('proofAsFields', proofAsFields);
        expect(vkAsFields).to.be.of.length(114);
        console.log('vkAsFields', vkAsFields);
        expect(vkHash).to.be.a('string');

        //ab7f5360ffb7

        secondRecursiveInputs = {
          verification_key: vkAsFields,
          proof: proofAsFields,
          public_inputs: [secondInput.y],
          key_hash: vkHash,
        };

        fs.writeFileSync('secondRecursiveInputs.json', JSON.stringify(secondRecursiveInputs));
      });

      it('Should generate a final proof with a recursive input', async () => {
        // const recursiveInputs = {
        //   first_proof: intermediateProof.proof,
        //   first_public_inputs: intermediateProof.publicInputs,
        //   second_proof: secondIntermediateProof.proof,
        //   second_public_inputs: secondIntermediateProof.publicInputs,
        // };
        finalProof = await noirs.recursive.generateFinalProof(recursiveInputs);
        expect(finalProof.proof instanceof Uint8Array).to.be.true;
      });
    });

    describe('Proof verification', async () => {
      let verifierContract: any;

      before(async () => {
        verifierContract = await viem.deployContract('UltraVerifier');
      });

      it('Should verify off-chain', async () => {
        const verified = await noirs.recursive.verifyFinalProof(finalProof);
        expect(verified).to.be.true;
      });

      // it('Should verify on-chain', async () => {
      //   const verified = await verifierContract.read.verify(
      //     bytesToHex(finalProof.proof),
      //     finalProof.publicInputs,
      //   );
      //   expect(verified).to.be.true;
      // });
    });
  });
});
