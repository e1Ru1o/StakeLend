"use client";

import { useRef, useState } from "react";
import { Address } from "~~/components/scaffold-eth";

export const DepositModal = ({ address }: { address: string }) => {
    const myModal = useRef<HTMLDialogElement>(null);
    const [amountInput, setAmountInput] = useState("");
    const handleDeposit = async (event: React.FormEvent) => {
        event.preventDefault();
        console.log(address);
        console.log(amountInput);
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
                <input
                    className="border-primary bg-base-100 text-base-content p-2 mr-2 w-full rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-accent"
                    type="text"
                    value={amountInput}
                    placeholder="Enter amount"
                    onChange={e => setAmountInput(e.target.value)}
                />
                <button className="btn" type="submit">Create deposit</button>
            </form>
            </div>
        </div>
        </dialog>
        </>
      );
}