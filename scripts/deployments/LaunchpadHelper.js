const hre = require("hardhat");
const fs = require('fs');

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const launchpadHelperFactory = await hre.ethers.getContractFactory('LaunchpadHelper');

    const launchpadHelper = await launchpadHelperFactory.deploy(
        '0x0000000000000000000000000000000000000000'
    );
    await launchpadHelper.deployed();
    console.log("launchpadHelper depolyed to:", launchpadHelper.address);

    const addresses = {
        launchpadHelper: launchpadHelper.address,
    };

    console.log(addresses);

    fs.writeFileSync(`${__dirname}/LaunchpadHelper.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
