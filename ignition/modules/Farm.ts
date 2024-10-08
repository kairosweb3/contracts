import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

const USDC_ADDRESS = "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913";
const CHAOS_ADDRESS = ethers.ZeroAddress;

export default buildModule("FarmModule", m => {
	const farm = m.contract("Farm", [CHAOS_ADDRESS, USDC_ADDRESS]);

	return { farm };
});
