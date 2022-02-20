import { ethers, upgrades } from 'hardhat';

async function main() {
    const Main = await ethers.getContractFactory("GoodleVault");
    const proxy = await upgrades.upgradeProxy("0xc45e7435460a2474e8711ffd463450347e48e52a", Main);
    console.log("contracts upgraded");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });