import type { NextPage } from "next";
import { Address } from "~~/components/scaffold-eth";
import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";
import { NewVaultModal } from "./_components/newVaultModal";
// import { DepositModal } from "./_components/depositModal";

export const metadata = getMetadata({
  title: "Created Vaults",
  description: "View the vaults you created",
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

export const createdVaults: Vault[] = [
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
    address: "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",
    requiredAmount: 1231233.43,
    timestamp: 1742158940,
    rewardPercentage: 32424.5545,
    totalDeposit: 231233.43,
    status: VaultStatus.DEPOSITING,
  },
];

const Created: NextPage = () => {
  return (
    <>
      {createdVaults.map((v, i) => {
        return (
          <div className="card card-compact w-1/2 bg-base-100 shadow-xl" key={i}> 
            <div className="card-body">
              <div className="flex">
              <div className="flex-initial w-32 h-14"><Address address={v.address} /></div>
              <div className="flex-initial w-32 h-14">{v.requiredAmount} USDC</div>
              <div className="flex-initial w-32 h-14">{new Date(v.timestamp).toLocaleDateString()}</div>
              <div className="flex-initial w-32 h-14">{v.rewardPercentage / 100.0} %</div>
              <div className="flex-initial w-32 h-14">{v.totalDeposit} USDC</div>
            </div>
            <div className="card-actions justify-end">
              {/* <DepositModal address={v.address}/> */}
            </div>
          </div>
        </div>
        );
      })}
      <NewVaultModal/>
    </>
  );
};

export default Created;
