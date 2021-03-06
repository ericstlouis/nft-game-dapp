//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./libraries/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract MyGame is ERC721 {

    struct CharacterStats {    //blueprint or datatype
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //count or increment the tokenIds

    CharacterStats[] defaultCharacters;   //array of datatype

    mapping(uint256 => CharacterStats) public nftHolderStats;  //map a number to the characterStat struct
    mapping(address => uint256) public nftHolders;             // map the owner address to the tokenId

    struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
    }

    BigBoss public bigBoss;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);


    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        string memory bossName, // These new variables would be passed in via run.js or deploy.js.
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    )
    ERC721("ninjas", "NJ")
    {
        for(uint i = 0; i < characterNames.length; i += 1) {  //loop thorugh the character names array
            defaultCharacters.push(CharacterStats({       //push the character values that was deployed with smart contract into the defaultCharaters array
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            
            CharacterStats memory c = defaultCharacters[i];        
            console.log("Done intializing %s w/ %s. img %s", c.name, c.hp, c.imageURI);  //console logging the chararter from the deafault array
              _tokenIds.increment();  //increment to the nft that are made in deployment
        }

          bigBoss = BigBoss({
          name: bossName,
          imageURI: bossImageURI,
          hp: bossHp,
          maxHp: bossHp,
          attackDamage: bossAttackDamage
          });

         console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

        
        }

    function mintCharacterNFT(uint _characterIndex) external {  //a function that take the characterindex and a argument
        uint256 newItemId = _tokenIds.current();    //assign the current tokenId as a newitemId

        _safeMint(msg.sender, newItemId);   //assign to the token Id wallet

        //refering back to the mapping we did to map this to characterStats struct datatype 
        //this will update the charcter Values wh
        nftHolderStats[newItemId] = CharacterStats({    
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        nftHolders[msg.sender] = newItemId;  //see how owns it

        _tokenIds.increment();   //increment the tokenId so the next person that mint this will be unique
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);

    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterStats memory character = nftHolderStats[_tokenId];    //

         string memory strHp = Strings.toString(character.hp);
         string memory strMaxHp = Strings.toString(character.maxHp);
         string memory strAttackDamage = Strings.toString(character.attackDamage);

          string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          character.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
          character.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;

}

  function attackBoss() public {
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterStats storage player = nftHolderStats[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

      require (
    player.hp > 0,
    "Error: character must have HP to attack boss."
  );

  // Make sure the boss has more than 0 HP.
  require (
    bigBoss.hp > 0,
    "Error: boss must have HP to attack boss."
  );
  
  // Allow player to attack boss.
  if (bigBoss.hp < player.attackDamage) {
    bigBoss.hp = 0;
  } else {
    bigBoss.hp = bigBoss.hp - player.attackDamage;
  }

  // Allow boss to attack player.
  if (player.hp < bigBoss.attackDamage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - bigBoss.attackDamage;
  }
  
  // Console for ease.
  console.log("Boss attacked player. New player hp: %s\n", player.hp);

  emit AttackComplete(bigBoss.hp, player.hp);

}

function checkIfUserHasNFT() public view returns (CharacterStats memory) {
   uint256 userNftTokenId = nftHolders[msg.sender];
  // If the user has a tokenId in the map, return their character.
  if (userNftTokenId > 0) {
    return nftHolderStats[userNftTokenId];
  }
  // Else, return an empty character.
  else {
    CharacterStats memory emptyStruct;
    return emptyStruct;
   }
}

function getAllDefaultCharacters() public view returns (CharacterStats[] memory) {
  return defaultCharacters;
}

function getBigBoss() public view returns (BigBoss memory) {
  return bigBoss;
}
}