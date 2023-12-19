const GameToken = artifacts.require("GameToken");
const ExternalPlayer = artifacts.require("ExternalPlayer");
const AttackContract = artifacts.require("AttackContract");


module.exports = function(deployer) {
  const accountAddress = '0x371d57ca9a5f033eCf55b7419F88ec1893892A50';
  const totalSupply = 10000000; 
  deployer.deploy(GameToken, accountAddress, totalSupply).then(function() {
    return deployer.deploy(ExternalPlayer, GameToken.address);
  }).then(function() {
    return deployer.deploy(AttackContract, ExternalPlayer.address );
  });
};