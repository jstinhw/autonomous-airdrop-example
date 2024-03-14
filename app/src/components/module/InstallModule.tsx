"use client";
import { useReadContract, useWriteContract } from 'wagmi';
import AxiomModularClientAbi from "@/lib/abi/AxiomModularClient.json";
import LoadingAnimation from "@/components/ui/LoadingAnimation";
import AdvanceStepButton from "../ui/AdvanceStepButton";
import Button from "../ui/Button";
import { useState, useEffect } from "react";
import { encodeAbiParameters, parseAbiParameters } from 'viem'

export default function InstallModule() {
  const {data, isLoading}: {data: any, isLoading: boolean} = useReadContract({
    abi: AxiomModularClientAbi.abi,
    address: '0x49Fd75973F8FDa1c5bb74dBA9f16E623035043E6',
    functionName: 'modules',
    args: ["0x04931c0f5479ab90a0333e6c96c81903045de82a115fc5260b723caea1ce9e17"]
  })
  const {writeContract: installWrite, data: installHash, isPending: isInstallPending} = useWriteContract();
  const {writeContract: uninstallWrite, data: unInstallHash, isPending: isUninstallPending} = useWriteContract();

  const [validator, setValidator] = useState(!data || data?.[0] === "0x0000000000000000000000000000000000000000" ? '' : data[0]);
  const [executor, setExecutor] = useState(!data || data?.[1] === "0x0000000000000000000000000000000000000000" ? '' : data[1]);

  const disalbeUninstall = data?.[0] === "0x0000000000000000000000000000000000000000" && data?.[1] === "0x0000000000000000000000000000000000000000";
  const disableInstall = (data?.[0] === validator && data?.[1] === executor) || !validator || !executor;

  useEffect(() => {
    if (data) {
      setValidator(data[0]);
      setExecutor(data[1]);
    }
  }, [data])

  if (isLoading) {
    return (
      <div className="flex flex-row items-center font-mono gap-2">
        {"Finding installed module"} <LoadingAnimation />
      </div>
    );
  }
  return (
    <div className="flex flex-col items-center font-mono gap-5">
      <div className="pb-2 flex flex-col items-center">
        <label htmlFor="validator">Validator:</label>
        <select id="validator" value={validator} onChange={(e) => setValidator(e.target.value)}>
          <option value={""}>{}</option>
          <option value={"0xcaCd4DbE11f327ddbEd68B53c79b618bb119ED26"}>Airdrop Validator</option>
        </select>
        
        <label htmlFor="executor">Executor:</label>
        <select id="executor" value={executor} onChange={(e) => setExecutor(e.target.value)}>
          <option value={""}>{}</option>
          <option value={"0xeFAd3accc29b3D784FC386d33Ca0A0F7B7AB39D7"}>Airdrop Executor</option>
        </select>
      </div>
      <div className='flex justify-between items-center gap-2'>
        <Button
          loading={isInstallPending}
          disabled={disableInstall}
          onClick={() => {
            installWrite({
              address: '0x49Fd75973F8FDa1c5bb74dBA9f16E623035043E6',
              abi: AxiomModularClientAbi.abi,
              functionName: 'installModule',
              args: [
                "0x04931c0f5479ab90a0333e6c96c81903045de82a115fc5260b723caea1ce9e17",
                validator,
                executor,
                encodeAbiParameters(
                  parseAbiParameters('address, uint32'),
                  ["0x224Cc4e5b50036108C1d862442365054600c260C", 4_000_000]
                ),
                encodeAbiParameters(
                  parseAbiParameters('address'),
                  ["0x0a1D41818191DA0BaE62A6c0720e0fA020EAeAfD"]
                )
              ]
            })
          }}
        >
          {"Install Module"}
        </Button>
        <Button
          loading={isUninstallPending}
          disabled={disalbeUninstall}
          onClick={() => {
            uninstallWrite({
              address: '0x49Fd75973F8FDa1c5bb74dBA9f16E623035043E6',
              abi: AxiomModularClientAbi.abi,
              functionName: 'uninstallModule',
              args: ["0x04931c0f5479ab90a0333e6c96c81903045de82a115fc5260b723caea1ce9e17"]
            })
          }}
        >
          {"UnInstall Module"}
        </Button>
      </div>
      <AdvanceStepButton
        label="Back to Home"
        href={"/"}
      />
    </div>
  )
}