import { ssz } from '@lodestar/types';
import { concatGindices, createProof, ProofType } from '@chainsafe/persistent-merkle-tree';

import { createClient } from './client.js';
import { toHex, verifyProof } from './utils.js';

const BeaconState = ssz.deneb.BeaconState;
const BeaconBlock = ssz.deneb.BeaconBlock;

/**
 * @param {string|number} slot
 * @param {number} validatorIndex
 */
async function main(slot = 'finalized', validatorIndex = 10, url="https://lodestar-sepolia.chainsafe.io") {
    console.error({slot, validatorIndex, url});
    const client = await createClient(url);

    /** @type {import('@lodestar/api').ApiClientResponse} */
    let response;

    response = await client.debug.getStateV2(slot, 'ssz');
    if (!response.ok) {
        throw response.error;
    }

    const stateView = BeaconState.deserializeToView(response.response);

    response = await client.beacon.getBlockV2(slot);
    if (!response.ok) {
        throw response.error;
    }

    const blockView = BeaconBlock.toView(response.response.data.message);
    const blockRoot = blockView.hashTreeRoot();

    /** @type {import('@chainsafe/persistent-merkle-tree').Tree} */
    const tree = blockView.tree.clone();
    // Patching the tree by attaching the response in the `stateRoot` field of the block.
    tree.setNode(blockView.type.getPropertyGindex('stateRoot'), stateView.node);
    // Create a proof for the response of the validator against the block.
    const gI = concatGindices([
        blockView.type.getPathInfo(['stateRoot']).gindex,
        stateView.type.getPathInfo(['validators', validatorIndex]).gindex,
    ]);
    /** @type {import('@chainsafe/persistent-merkle-tree').SingleProof} */
    const p = createProof(tree.rootNode, { type: ProofType.single, gindex: gI });

    // Sanity check: verify gIndex and proof match.
    verifyProof(blockRoot, gI, p.witnesses, stateView.validators.get(validatorIndex).hashTreeRoot());

    // Since EIP-4788 stores parentRoot, we have to find the descendant block of
    // the block from the response.
    response = await client.beacon.getBlockHeaders({ parentRoot: toHex(blockRoot) });
    if (!response.ok) {
        throw response.error;
    }

    /** @type {import('@lodestar/types/lib/phase0/types.js').SignedBeaconBlockHeader} */
    const nextBlock = response.response.data[0]?.header;
    if (!nextBlock) {
        throw new Error('No block to fetch timestamp from');
    }

    return {
        blockRoot: toHex(blockRoot),
        proof: p.witnesses.map(toHex),
        validator: stateView.validators.type.elementType.toJson(stateView.validators.get(validatorIndex)),
        validatorIndex: validatorIndex,
        ts: client.slotToTS(nextBlock.message.slot),
        gI,
    };
}

main(process.argv[2], process.argv[3], process.argv[4]).then(console.log).catch(console.error);
