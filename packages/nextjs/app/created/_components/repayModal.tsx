"use client";

import { useRef, useState } from "react";
import { Address as AddressType, ByteArray, parseEther, parseUnits } from "viem";
import { Address, AddressInput, Bytes32Input, BytesInput, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const RepayModal = ({ address }: { address: string }) => {
    const myModal = useRef<HTMLDialogElement>(null);

    const { writeAsync, isLoading, isMining } = useScaffoldContractWrite({
        contractName: "StakeLend",
        functionName: "repay",
        args: [address],
        blockConfirmations: 1,
        onBlockConfirmation: txnReceipt => {
          console.log("Transaction blockHash", txnReceipt.blockHash);
          myModal.current?.close();
        },
      });

    const handleRepay = async (event: React.FormEvent) => {
        event.preventDefault();
        writeAsync();
        return;
      };

      return (
        <>
        <button className="btn" onClick={() => myModal.current?.showModal()}>Repay</button>
        <dialog id="my_modal_1" className="modal" ref={myModal}>
        <div className="modal-box">
            <form method="dialog">
                <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 className="font-bold text-lg">Repay</h3>
            <div className="modal-action">
            <form onSubmit={handleRepay} className="flex items-center justify-end mb-5 space-x-3 mx-5">
                <Address address={address} />
                <button className="btn" type="submit">Repay</button>
            </form>
            </div>
        </div>
        </dialog>
        </>
      );
}