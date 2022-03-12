const hre = require("hardhat");
const fs = require('fs');

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[1];
    console.log('signer:', signer.address);

    const wNETTFactory = await hre.ethers.getContractFactory('wNETT');

    const wNETT = await wNETTFactory.connect(signer).deploy();
    await wNETT.deployed();
    console.log("wNETT depolyed to:", wNETT.address);

    const addresses = {
        wNETT: wNETT.address,
    };

    console.log(addresses);

    fs.writeFileSync(`${__dirname}/wNETT-588.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
