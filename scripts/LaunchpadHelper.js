const hre = require("hardhat");
const fs = require('fs');
const padFactory = require('./PadFactoryProxy-588.json');

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const PadFactoryFactory = await hre.ethers.getContractFactory('PadFactory');
    const launchpadHelperFactory = await hre.ethers.getContractFactory('LaunchpadHelper');

    const PadFactoryProxy = PadFactoryFactory.attach(padFactory.PadFactoryProxy);

    const launchpadHelper = await launchpadHelperFactory.deploy(
        PadFactoryProxy.address
    );
    await launchpadHelper.deployed();
    console.log("launchpadHelper depolyed to:", launchpadHelper.address);

    const addresses = {
        launchpadHelper: launchpadHelper.address,
    };

    console.log(addresses);

    fs.writeFileSync(`${__dirname}/LaunchpadHelper-599.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
