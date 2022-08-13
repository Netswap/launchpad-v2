const hre = require("hardhat");
const fs = require('fs');
const unlimited = require('./Unlimited.json');
const wNETT = require('../wNETT-mainnet.json');
const wNETTStaking = require('../wNETTStakingProxy-mainnet.json');
const helper = require('./LaunchpadHelper.json');

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const PadFactoryFactory = await hre.ethers.getContractFactory('PadFactory');
    const wNETTStakingFactory = await hre.ethers.getContractFactory('wNETTStaking');
    const helperFactory = await hre.ethers.getContractFactory('LaunchpadHelper');

    const wNETTStakingProxy = wNETTStakingFactory.attach(wNETTStaking.wNETTStakingProxy);
    const LaunchpadHelper = helperFactory.attach(helper.launchpadHelper);

    const PadFactoryProxy = await hre.upgrades.deployProxy(
        PadFactoryFactory,
        [
            unlimited.Unlimited,
            unlimited.Unlimited,
            wNETT.wNETT,
            signer.address
        ]
    );
    await PadFactoryProxy.deployed();
    console.log("PadFactoryProxy depolyed to:", PadFactoryProxy.address);

    const addresses = {
        PadFactoryProxy: PadFactoryProxy.address,
    };

    console.log(addresses);

    fs.writeFileSync(`${__dirname}/PadFactoryProxy.json`, JSON.stringify(addresses, null, 4));

    // set pad factory address for wNETTStaking
    console.log('=== setting up PadFactory for wNETTStaking ===');
    await wNETTStakingProxy.setPadFactory(PadFactoryProxy.address);
    console.log('PadFactory set done for wNETTStaking');

    // set pad factory address for helper contract
    console.log('=== setting up PadFactory for LaunchpadHelper ===');
    await LaunchpadHelper.setPadFactory(PadFactoryProxy.address);
    console.log('PadFactory set done for LaunchpadHelper');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
