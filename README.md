## Sha2_512 - Solidity

An implementation of SHA2 - 512 bits Cryptographic Hash Algorithm.

#### Its not working yet

#### Example and Test:

```js
import chai, {expect} from 'chai';
import { ethers, utils } from 'ethers';
import CryptoJS from 'crypto-js';
import {createMockProvider, deployContract, getWallets, solidity} from 'ethereum-waffle';

import Sha512 from '../../build/Sha512';

chai.use(solidity);

describe('Sha512 contracts test', async () => {
	let provider;
	let accounts;
	let wallet;
	let anotherWallet;
	let contract;

	beforeEach(async () => {
		provider = await createMockProvider({ gasLimit: 8000000000 });
		accounts = await getWallets(provider);
		[wallet, anotherWallet] = accounts;
		contract = await deployContract(wallet, Sha512, [], { gasLimit: 100000000 });
	});

	it("expect to return digest 'hello world'", async () => {
	  let result = await contract.digest("0x68656c6c6f20576f726c64");
	  let result_expected = CryptoJS.SHA512('hello world').toString(CryptoJS.enc.Hex);

	  expect(
	    result.reduce((prev,e) => prev + e._hex.replace('0x',''), "")
	  ).to.be.eq(result_expected);
	});

});

```