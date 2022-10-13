const hre = require("hardhat");
const fs = require('fs');
const wNETT_addr = require('./wNETT-599.json');
const NETT_MAINNET = '0xA49efFF1961C0aF60519887E390e9954952176f8'

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const wNETTStakingFactory = await hre.ethers.getContractFactory('wNETTStaking');
    const wNETTFactory = await hre.ethers.getContractFactory('wNETT');

    const wNETT = wNETTFactory.attach(wNETT_addr.wNETT);

    const wNETTStakingProxy = await hre.upgrades.deployProxy(
        wNETTStakingFactory, 
        [
            NETT_MAINNET,
            wNETT.address,
            '5000000000000000000',
            Math.round(Date.now() / 1000)
        ]
    );
    await wNETTStakingProxy.deployed();
    console.log("wNETTStakingProxy depolyed to:", wNETTStakingProxy.address);

    const addresses = {
        wNETTStakingProxy: wNETTStakingProxy.address,
    };

    console.log(addresses);

    // transfer wNETT owner to wNETTStaking
    await wNETT.connect(signer).transferOwnership(wNETTStakingProxy.address);
    console.log('wNETT ownership transferred');

    fs.writeFileSync(`${__dirname}/wNETTStakingProxy-599.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
