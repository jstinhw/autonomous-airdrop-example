"use client";
import AdvanceStepButton from '@/components/ui/AdvanceStepButton'
import Title from '@/components/ui/Title'
import CodeBox from '@/components/ui/CodeBox';
import Link from 'next/link';
import { useReadContract } from 'wagmi';
import AxiomModularClientAbi from "@/lib/abi/AxiomModularClient.json";
import LoadingAnimation from "@/components/ui/LoadingAnimation";

export default function Home() {
  const {data, isLoading}: {data: any, isLoading: boolean} = useReadContract({
    abi: AxiomModularClientAbi.abi,
    address: '0x49Fd75973F8FDa1c5bb74dBA9f16E623035043E6',
    functionName: 'modules',
    args: ["0x04931c0f5479ab90a0333e6c96c81903045de82a115fc5260b723caea1ce9e17"]
  })
  const disabled = data?.[0] === "0x0000000000000000000000000000000000000000";

  let compiledCircuit;
  try {
    compiledCircuit = require("../../axiom/data/compiled.json");
  } catch (e) {
    console.log(e);
  }
  if (compiledCircuit === undefined) {
    return (
      <>
        <div>
          Compile circuit first by running in the root directory of this project:
        </div>
        <CodeBox>
          {"npx axiom compile circuit app/axiom/swapEvent.circuit.ts"}
        </CodeBox>
      </>
    )
  }
  if (isLoading) {
    return (
      <div className="flex flex-row items-center font-mono gap-2">
        {"Finding installed module"} <LoadingAnimation />
      </div>
    );
  }

  return (
    <>
      <Title>
        Autonomous Airdrop Example
      </Title>
      <div className="text-center">
        {
          disabled ? 
          "Install the Axiom client to continue." : 
          `Anyone who has used ${<Link href="https://app.uniswap.org/swap" target="_blank">Uniswap</Link>} to
          swap in the UniswapV3 UNI-WETH pool on Sepolia testnet after block 4000000 is eligible for an 
          airdrop of a useless test ERC20 token. You may need to wait a few minutes after executing your
          swap for the indexer to pick it up.`
        }
      </div>
      <div className="flex justify-between items-center space-x-4">
        <AdvanceStepButton
          label="Manage Axiom Client"
          href={"/module"}
        />
        {!disabled && <AdvanceStepButton
          label="Generate Proof"
          href={"/check"}
        />}
      </div>
      
    </>
  )
}