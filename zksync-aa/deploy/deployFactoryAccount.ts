import { utils, Wallet, Provider, types, EIP712Signer } from "zksync-ethers";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// load env file
import dotenv from "dotenv";
dotenv.config();

const DEPLOYER_PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY || "";

export default async function (hre: HardhatRuntimeEnvironment) {
  // @ts-ignore target zkSyncSepoliaTestnet in config file which can be testnet or local
  const provider = new Provider(hre.config.networks.zkSyncSepoliaTestnet.url);
  const wallet = new Wallet(DEPLOYER_PRIVATE_KEY, provider);
  const deployer = new Deployer(hre, wallet);
  const factoryArtifact = await deployer.loadArtifact("AAFactory");
  const aaArtifact = await deployer.loadArtifact("Account");

  let ethTransferTx = {
    from: wallet.address,
    to: "0x656640299E8e4c3EADCb7c9C89F013DCE9312B33", // account that will receive the ETH transfer
    chainId: (await provider.getNetwork()).chainId,
    nonce: 1,
    type: 113,
    customData: {
      gasPerPubdata: utils.DEFAULT_GAS_PER_PUBDATA_LIMIT,
    } as types.Eip712Meta,

    value: ethers.parseEther("0.01"),
    gasPrice: await provider.getGasPrice(),
    gasLimit: BigInt(20000000), // constant 20M since estimateGas() causes an error and this tx consumes more than 15M at most
    data: "0x",
  };

  console.log("ethTransferTx: ", ethTransferTx);

  const signedInput = EIP712Signer.getSignInput(ethTransferTx);

  console.log("signedInput: ", signedInput);

  const signedTxHash = EIP712Signer.getSignedDigest(ethTransferTx);

  console.log("signedTxHash: ", signedTxHash);

  const signature = ethers.concat([
    ethers.Signature.from(wallet.signingKey.sign(signedTxHash)).serialized,
  ]);

  console.log("signature: ", signature);
}
