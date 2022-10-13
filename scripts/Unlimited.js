const hre = require("hardhat");
const fs = require('fs');

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const UnlimitedFactory = await hre.ethers.getContractFactory('Unlimited');

    const Unlimited = await UnlimitedFactory.deploy();
    await Unlimited.deployed();
    console.log("Unlimited depolyed to:", Unlimited.address);

    const addresses = {
        Unlimited: Unlimited.address,
    };

    console.log(addresses);

    fs.writeFileSync(`${__dirname}/Unlimited-599.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
