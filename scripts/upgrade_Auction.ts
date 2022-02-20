import { ethers, upgrades } from 'hardhat';

async function main() {
    const Main = await ethers.getContractFactory("GoodleAuction");
    const proxy = await upgrades.upgradeProxy("0x935861E22cD14479858Dff25FF9874f884eA2577", Main);
    console.log("contracts upgraded");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });