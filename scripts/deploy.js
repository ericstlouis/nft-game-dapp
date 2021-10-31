const { ethers } = require('hardhat');
const fs = require('fs');


const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyGame');
  const gameContract = await gameContractFactory.deploy(
    ['Boruto', 'Sarada', 'Mitsuki', 'Kawaki'], //names
    [
      'https://i.imgur.com/wiBer51.jpeg', //Images
      'https://i.imgur.com/MAz0665.jpeg',
      'https://i.imgur.com/YePhKon.jpeg',
      'https://i.imgur.com/JVCd9xl.jpeg',
    ],
    [250, 400, 350, 300], //HP
    [500, 350, 400, 350], //attack
    'Isshiki Otsutsuki', // Boss name
    'https://i.imgur.com/i6OKJY2.png', // Boss image
    10000, // Boss hp
    50 // Boss attack damage
  );
  await gameContract.deployed();
  console.log('contract deployed to:', gameContract.address);

   let addresses = { GameContract: gameContract.address};
   let addressesJSON = JSON.stringify(addresses);
   fs.writeFileSync('src/contract-address.json', addressesJSON);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); 
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
