const hre = require("hardhat");
const fs = require('fs');
const wNETT_addr = require('./wNETT-588.json');
const NETT_588 = '0x8127bd4C0e71d5B1f4B28788bb8C4708b51934F9'

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[1];
    console.log('signer:', signer.address);

    const wNETTStakingFactory = await hre.ethers.getContractFactory('wNETTStaking');
    const wNETTFactory = await hre.ethers.getContractFactory('wNETT');

    const wNETT = wNETTFactory.attach(wNETT_addr.wNETT);

    const wNETTStaking = await hre.upgrades.deployProxy(
        wNETTStakingFactory, 
        [
            NETT_588,
            wNETT.address,
            '5000000000000000000',
            Math.floor(Date.now() / 1000 + 60)
        ]
    );
    await wNETTStaking.deployed();
    console.log("wNETTStaking depolyed to:", wNETTStaking.address);

    const addresses = {
        wNETTStaking: wNETTStaking.address,
    };

    console.log(addresses);

    // transfer wNETT owner to wNETTStaking
    await wNETT.connect(signer).transferOwnership(wNETTStaking.address);
    console.log('wNETT ownership transferred');

    fs.writeFileSync(`${__dirname}/wNETTStaking-588.json`, JSON.stringify(addresses, null, 4));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
