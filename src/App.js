import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import './bulma2.css';
import BalancesMenu from './Components/Balances';
import Home from './Components/Home';
import Inventory from './Components/Inventory';
import Transfer from './Components/Transfer';
import Footer from './Components/Footer';
import HeroBanner from './Components/HeroBanner';
import Web3 from 'web3';

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');

  useEffect(() => {
    async function connectWeb3() {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        try {
          await window.ethereum.enable();
          setWeb3(web3);
          const accounts = await web3.eth.getAccounts();
          if (accounts.length > 0) {
            setAccount(accounts[0]);
          }
        } catch (error) {
          console.error(error);
        }
      }
    }
    connectWeb3();
  }, []);

  return (
    <div className='main'>
      <HeroBanner />
      <Router>
        <div className="app main">
          <div> 
            <BalancesMenu web3={web3} account={account} />
            <nav>
              <ul className='header columns has-background-grey is-centered px-4 has-text-dark'>
                <li className="column is-active"><Link to="/">Homepage</Link></li>
                <li className="column is-active"><Link to="/Inventory">Inventory</Link></li>
                <li className="column is-active"><Link to="/Transfer">Transfer</Link></li>
              </ul>
            </nav>
          </div>
        </div>
        <div className='is-max-widescreen'>
          <Routes>
            <Route exact path="/" element={<Home />} />
            <Route path="/Inventory" element={<Inventory />} />
            <Route path="/Transfer" element={<Transfer />} />
          </Routes>
        </div>
        <Footer />
      </Router>
    </div>
  );
};

export default App;
