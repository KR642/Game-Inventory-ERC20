import React, { useEffect, useState } from 'react';
import Web3 from 'web3';
import { CONTRACTS } from './environment.js';

const BalancesMenu = ({ account }) => {
  const [tokenBalance, setTokenBalance] = useState(0);
  const [etherBalance, setEtherBalance] = useState(0);
  const [tokenReward, setTokenReward] = useState(0);

  const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545');
  const GameToken = new web3.eth.Contract(CONTRACTS.GAMETOKEN_ABI, CONTRACTS.GAMETOKEN_ADDRESS);
  
  // effect to get token balance
  useEffect(() => {
    const load = async () => {
      const tokenBalance = await GameToken.methods.balanceOf(account).call({ from: account });
      setTokenBalance(tokenBalance);
    };
    load();
  }, [account]);

  // effect to get ether balance
  useEffect(() => {
    const load = async () => {
      const etherBalance = await web3.eth.getBalance(account);
      setEtherBalance(web3.utils.fromWei(etherBalance, 'ether'));
    };
    load();
  }, [account]);

  // effect to get token reward by the game won
  useEffect(() => {
    const load = async () => {
      const tokenReward = await GameToken.methods.getReward(account).call({ from: account });
      setTokenReward(tokenReward);
    };
    load();
  }, [account]);
  
  return (
    <div className="balancesmenu">
      <div className="balanceCenter">
        <div className="balance-item">
          <span className="label">Token Balance: </span>
          <span>{tokenBalance}</span>
        </div>
        <div className="balance-item">
          <span className="label">ETHER Balance: </span>
          <span>{etherBalance}</span>
        </div>
        <div className="balance-item">
          <span className="label">Token Reward: </span>
          <span>{tokenReward}</span>
        </div>
      </div>
    </div>
  );
};

export default BalancesMenu;
