import { useState } from 'react';
import Web3 from 'web3';
import { CONTRACTS } from './environment.js';

function Home() {
  const [joinStatus, setJoinStatus] = useState('');

  const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545');
  const ExternalPlayer = new web3.eth.Contract(CONTRACTS.EXTERNALPLAYER_ABI, CONTRACTS.EXTERNALPLAYER_ADDRESS);

  // join game by sending 1 ETHER to the contract address by the players
  const joinGame = async () => {
    const accounts = await web3.eth.getAccounts();
    const fromAddress = accounts[0];
    try {
      await ExternalPlayer.methods.sendEtherToContract().send({ from: fromAddress, value: web3.utils.toWei('1', 'ether') });
      setJoinStatus("You have joined the game, wait for Admin to send the tokens.");
    } catch (error) {
      console.error(error);
      setJoinStatus("Failed to join the game. Please try again.");
    }
  }
  return (
    <div className="menupage">
      <div className='divform'>
        <h1 className="is-size-4">Join the game</h1>
        <p>The amount required to join the game is 1 ETHER.</p>
        <button className='button is-primary' onClick={joinGame}>Join</button>
        {joinStatus && <p>{joinStatus}</p>}
      </div>
    </div>
  );
};

export default Home;
