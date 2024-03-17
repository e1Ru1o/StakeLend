import type { NextPage } from "next";
import { Address } from "~~/components/scaffold-eth";
import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";
import { DepositModal } from "./_components/depositModal";

export const metadata = getMetadata({
  title: "Vaults",
  description: "View your vaults",
});

type Vault = {
  address: string;
  requiredAmount: number;
  timestamp: number;
  rewardPercentage: number;
  totalDeposit: number;
  status: VaultStatus;
};

enum VaultStatus {
  DEPOSITING,
  LENDING,
  LIQUIDATED,
  REPAID,
  CANCELLED
}

export const vaults: Vault[] = [
  {
    address: "0x26D2DfdFc9C7af78e60F5a2450a6C2544D59f42A",
    requiredAmount: 1231233.43,
    timestamp: 1710622940,
    rewardPercentage: 32424.5545,
    totalDeposit: 231233.43,
    status: VaultStatus.DEPOSITING,
  },
  {
    address: "0x26D2DfdFc9C7af78e60F5a2450a6C2544D59f42A",
    requiredAmount: 1231233.43,
    timestamp: 1742158940,
    rewardPercentage: 32424.5545,
    totalDeposit: 231233.43,
    status: VaultStatus.DEPOSITING,
  },
  {
    address: "0x26D2DfdFc9C7af78e60F5a2450a6C2544D59f42A",
    requiredAmount: 1231233.43,
    timestamp: 1742158940,
    rewardPercentage: 32424.5545,
    totalDeposit: 231233.43,
    status: VaultStatus.DEPOSITING,
  },
];

const Vaults: NextPage = () => {
  return (
    <>
      {vaults.map((v, i) => {
        return (
          <div className="card card-compact w-1/2 bg-base-100 shadow-xl">
          <div className="card-body">
            <div className="flex">
            <div className="flex-initial w-32 h-14"><Address address={v.address} /></div>
            <div className="flex-initial w-32 h-14">{v.requiredAmount} USDC</div>
            <div className="flex-initial w-32 h-14">{new Date(v.timestamp).toLocaleDateString()}</div>
            <div className="flex-initial w-32 h-14">{v.rewardPercentage / 100.0} %</div>
            <div className="flex-initial w-32 h-14">{v.totalDeposit} USDC</div>
          </div>
            <div className="card-actions justify-end">
              <DepositModal address={v.address}/>
            </div>
          </div>
        </div>
        );
      })}
    </>
  );
};

export default Vaults;
