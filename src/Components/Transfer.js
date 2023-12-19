import React, { useEffect, useState } from 'react';
import Web3 from 'web3';
import { CONTRACTS } from './environment.js';

const Transfer = () => {
  const [transferAmount, setTransferAmount] = useState(0);
  const [toAddress, setToAddress] = useState('');
  const [getAmount, setGetAmount] = useState(0);
  const [sendAddress, setSendAddress] = useState('');
  const [receiverAddress, setReceiverAddress] = useState('');
  const [allowanceAmount, setAllowanceAmount] = useState(0);

  const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545');
  const GameToken = new web3.eth.Contract(CONTRACTS.GAMETOKEN_ABI, CONTRACTS.GAMETOKEN_ADDRESS);

  // handle submit for the transfer function 
  const handleTransferSubmit = async (event) => {
    event.preventDefault();
    const accounts = await web3.eth.getAccounts();
    const fromAddress = accounts[0];
    await GameToken.methods.transfer(toAddress, transferAmount).send({ from: fromAddress });
  };

  // handle submit for the transfer from function 
  const handleGetSubmit = async (event) => {
    event.preventDefault();
    const accounts = await web3.eth.getAccounts();
    const fromAddress = accounts[0];
    await GameToken.methods.transferFrom(sendAddress, receiverAddress, getAmount).send({ from: fromAddress });
  };

  // use effect to get the allownance balance
  useEffect(() => {
    const load = async () => {
      const accounts = await web3.eth.getAccounts();
      const fromAddress = accounts[0];
      const adminAccount = '0xC2c2E797432346917de674033DBD70d10C21EEdc';
      const allowanceAmount = await GameToken.methods.allowance(adminAccount, fromAddress).call({ from: fromAddress });
      setAllowanceAmount(allowanceAmount);
    };
    load();
  }, []);
  

  return (
    <div className="transfer-container columns">
      <div className="transfer-section column">
        <h3 className="transfer-section-title is-size-4">Transfer Token</h3>
        <p>Send token to a player</p>
        <form onSubmit={handleTransferSubmit}>
          <label>
            To:
            <input className='input is-primary'
              type="text"
              value={toAddress}
              onChange={(event) => setToAddress(event.target.value)}
            />
          </label>
          <label>
            Amount:
            <input className='input is-primary'
              type="text"
              value={transferAmount}
              onChange={(event) => setTransferAmount(event.target.value)}
            />
          </label>
          <button className="button is-primary" type="submit">
            Send
          </button>
        </form>
      </div>
      <div className="transfer-section column">
        <h3 className="transfer-section-title is-size-4">Get your allowance</h3>
        <form onSubmit={handleGetSubmit}>
          <div className="transfer-section-allowance">
            <p>Allowance Balance:<span>{allowanceAmount}</span></p>
          </div>
          <label>
            From:
            <input className='input is-primary'
              type="text"
              value={sendAddress}
              onChange={(event) => setSendAddress(event.target.value)}
            />
          </label>
          <label>
            To:
            <input className='input is-primary'
              type="text"
              value={receiverAddress}
              onChange={(event) => setReceiverAddress(event.target.value)}
            />
          </label>
          <label>
            Amount:
            <input className='input is-primary'
              type="text"
              value={getAmount}
              onChange={(event) => setGetAmount(event.target.value)}
            />
          </label>
          <button className="button is-primary" type="submit">
            Get
          </button>
        </form>
      </div>
    </div>
  );
};

export default Transfer;
