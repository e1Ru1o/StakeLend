"use client";

import { useRef, useState } from "react";
import { parseEther, parseUnits } from "viem";
import { Address, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const NewVaultModal = () => {
    const myModal = useRef<HTMLDialogElement>(null);
    const [requiredAmount, setRequiredAmount] = useState("");
    const [deadline, setDeadline] = useState("");
    const [rewardBPS, setRewardBPS] = useState("");
    const parseEtherFromStringOrBigInt = (value: string | bigint): bigint => {
      if (typeof value === "string") 
      {
        return parseEther(value);
      }
      else
      {
        return value;
      }
    }
    const { writeAsync, isLoading, isMining } = useScaffoldContractWrite({
        contractName: "StakeLend",
        functionName: "createVault",
        args: [parseEtherFromStringOrBigInt(requiredAmount), parseUnits(deadline, 1), parseUnits(rewardBPS, 1)],
        blockConfirmations: 1,
        onBlockConfirmation: txnReceipt => {
          console.log("Transaction blockHash", txnReceipt.blockHash);
          myModal.current?.close();
        },
      });

    const handleCreateNewVault = async (event: React.FormEvent) => {
        event.preventDefault();
        writeAsync();
        return;
      };

      return (
        <>
        <button className="btn" onClick={() => myModal.current?.showModal()}>Create new vault</button>
        <dialog id="my_modal_1" className="modal" ref={myModal}>
        <div className="modal-box">
            <form method="dialog">
                <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 className="font-bold text-lg">Create a deposit</h3>
            <div className="modal-action">
            <form onSubmit={handleCreateNewVault} className="flex items-center justify-end mb-5 space-x-3 mx-5">
                <input
                    className="border-primary bg-base-100 text-base-content p-2 mr-2 w-full rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-accent"
                    type="text"
                    value={requiredAmount}
                    placeholder="Enter amount"
                    onChange={e => setRequiredAmount(e.target.value)}
                />
                <input
                    className="border-primary bg-base-100 text-base-content p-2 mr-2 w-full rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-accent"
                    type="text"
                    value={deadline}
                    placeholder="Enter deadline"
                    onChange={e => setDeadline(e.target.value)}
                />
                <input
                    className="border-primary bg-base-100 text-base-content p-2 mr-2 w-full rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-accent"
                    type="text"
                    value={rewardBPS}
                    placeholder="Enter reward BPS"
                    onChange={e => setRewardBPS(e.target.value)}
                />
                <button className="btn" type="submit">Create</button>
            </form>
            </div>
        </div>
        </dialog>
        </>
      );
}