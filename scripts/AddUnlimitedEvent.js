const hre = require("hardhat");
const PadFactory = require('./PadFactoryProxy-599.json');
const helper = require('./LaunchpadHelper-599.json');
const TUSDC = '0x4D0D58a7AD8223E6d5F983A8cDeB1E354ED0ced9'
const TEST = '0xE5991f3b3D468e6C904f56a4d9C0613c3e3aB4dB';

async function main() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log('signer:', signer.address);

    const PadFactoryFactory = await hre.ethers.getContractFactory('PadFactory');
    const launchpadHelperFactory = await hre.ethers.getContractFactory('LaunchpadHelper');
    const PadFactoryProxy = PadFactoryFactory.attach(PadFactory.PadFactoryProxy);

    const helperContract = launchpadHelperFactory.attach(helper.launchpadHelper);

    const args = {
        _issuer: signer.address,
        _issuedToken: TEST,
        _paymentToken: TUSDC,
        // 2500000 HUM
        _issuedTokenAmount: '2500000000000000000000000',
        // $0.1
        _price: '100000000000000000',
        // Apr 12 15:00 UTC
        _depositStartTime: 1649775600,
        _depositDuration: 259200,
        // Apr 19 19:00 UTC
        _launchTime: 1650308400,
        _decimals: '1000000000000000000',
        // $50
        _minDeposit: '50000000',
    }
    console.log('==== adding unlimited event ====');
    await PadFactoryProxy.createNewUnlimitedModel(
        args._issuer,
        args._issuedToken,
        args._paymentToken,
        args._issuedTokenAmount,
        args._price,
        args._depositStartTime,
        args._depositDuration,
        args._launchTime,
        args._decimals,
        args._minDeposit,
    );
    console.log("New unlimited event added");

    const models = await helperContract.getAllUnlimitedEvents(0, 100);
    console.log(models);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });