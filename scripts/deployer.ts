import { ethers , upgrades} from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';


async function main() {
    const teamMultiSig = "0xB107953a6d3114D887244c5e6f424a0deBbEf33C";
    const BaseURI = "https://gateway.pinata.cloud/ipfs/";

    const GoodleVault = await ethers.getContractFactory('GoodleVault');
    const goodleVault = await upgrades.deployProxy(GoodleVault, [teamMultiSig], {
        kind: "uups"
    });
    const goodleVault_contract = await goodleVault.deployed();

    console.log("goodleVault_contract", goodleVault_contract.address);


    const GoodleNFT = await ethers.getContractFactory('GoodleNFT');
    const goodleNFT = await GoodleNFT.deploy("GoodleNFT", "GNFT");
    const goodleNFT_contract = await goodleNFT.deployed();

    console.log("goodleNFT_contract", goodleNFT_contract.address);

    const GoodleAuction = await ethers.getContractFactory('GoodleAuction');
    const goodleAuction = await upgrades.deployProxy(GoodleAuction, [goodleNFT_contract.address, goodleVault_contract.address], {
        kind: "uups"
    });
    const goodleAuction_contract = await goodleAuction.deployed();

    console.log("goodleAuction_contract", goodleAuction_contract.address);

    //set
    await goodleNFT_contract.setGoodleAuction(goodleAuction_contract.address);

    await goodleNFT_contract.setBaseURI(BaseURI);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
