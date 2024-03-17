"use client";

import { useRef, useState } from "react";
import { Address as AddressType, ByteArray, parseEther, parseUnits } from "viem";
import { Address, AddressInput, Bytes32Input, BytesInput, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const LendModal = ({ address }: { address: string }) => {
    const myModal = useRef<HTMLDialogElement>(null);

    // const [inputAddress, setInputAddress] = useState<AddressType>();
    const [pk, setPk] = useState("");
    const [signature, setSignature] = useState("");
    const [depositDataRoot, setDepositDataRoot] = useState("");

    const { writeAsync, isLoading, isMining } = useScaffoldContractWrite({
        contractName: "StakeLend",
        functionName: "lend",
        args: [address, pk as `0x${string}`, signature as `0x${string}`, depositDataRoot as `0x${string}`],
        blockConfirmations: 1,
        onBlockConfirmation: txnReceipt => {
          console.log("Transaction blockHash", txnReceipt.blockHash);
          myModal.current?.close();
        },
      });

    const handleLend = async (event: React.FormEvent) => {
        event.preventDefault();
        writeAsync();
        return;
      };

      return (
        <>
        <button className="btn" onClick={() => myModal.current?.showModal()}>Lend</button>
        <dialog id="my_modal_1" className="modal" ref={myModal}>
        <div className="modal-box">
            <form method="dialog">
                <button className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 className="font-bold text-lg">Lend</h3>
            <div className="modal-action">
            <form onSubmit={handleLend} className="flex items-center justify-end mb-5 space-x-3 mx-5">
                <Address address={address} />
                <BytesInput
                    placeholder="pk"
                    value={pk}
                    onChange={value => setPk(value)}
                />
                <BytesInput
                    placeholder="signature"
                    value={signature}
                    onChange={value => setSignature(value)}
                />
                <Bytes32Input
                    placeholder="signature"
                    value={signature}
                    onChange={value => setSignature(value)}
                />
                <button className="btn" type="submit">Lend</button>
            </form>
            </div>
        </div>
        </dialog>
        </>
      );
}