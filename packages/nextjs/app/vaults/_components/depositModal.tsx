"use client";

import { useRef, useState } from "react";
import { parseEther } from "viem";
import { Address, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const DepositModal = ({ address }: { address: string }) => {
    const myModal = useRef<HTMLDialogElement>(null);
    const [amountInput, setAmountInput] = useState("");
    // const parseEtherFromStringOrBigInt = (value: string | bigint): bigint => {
    //   if (typeof value === "string") 
    //   {
    //     return parseEther(value);
    //   }
    //   else
    //   {
    //     return value;
    //   }
    // }
    const { writeAsync, isLoading, isMining } = useScaffoldContractWrite({
        contractName: "StakeLend",
        functionName: "fillVault",
        args: [address, parseEther(amountInput)],
        blockConfirmations: 1,
        onBlockConfirmation: txnReceipt => {
          console.log("Transaction blockHash", txnReceipt.blockHash);
          myModal.current?.close();
        },
      });

    const handleDeposit = async (event: React.FormEvent) => {
        event.preventDefault();
        writeAsync();
        return;
      };

      return (
        <>
        <button className="btn" onClick={() => myModal.current?.showModal()}>Deposit</button>
        <dialog id="my_modal_1" className="modal" ref={myModal}>
        <div className="modal-box">
            <form method="dialog">
                <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 className="font-bold text-lg">Create a deposit</h3>
            <div className="modal-action">
            <Address address={address} />
            <form onSubmit={handleDeposit} className="flex items-center justify-end mb-5 space-x-3 mx-5">

              {/* <IntegerInput
                value={amountInput}
                onChange={updatedAmount => {
                    setAmountInput(updatedAmount);
                }}
                placeholder="value (wei)"
              /> */}

                <input
                    className="border-primary bg-base-100 text-base-content p-2 mr-2 w-full rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-accent"
                    type="text"
                    value={amountInput}
                    placeholder="Enter amount"
                    onChange={e => setAmountInput(e.target.value)}
                />
                <button className="btn" type="submit">Deposit</button>
            </form>
            </div>
        </div>
        </dialog>
        </>
      );
}