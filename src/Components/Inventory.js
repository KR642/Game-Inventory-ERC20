import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import { CONTRACTS } from './environment.js';

const Inventory = () => {
  const [ownedItems, setOwnedItems] = useState([]);
  const [inventoryItems, setInventoryItems] = useState([]);

  const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545');
  const GameToken = new web3.eth.Contract(CONTRACTS.GAMETOKEN_ABI, CONTRACTS.GAMETOKEN_ADDRESS);

  // get owned items by the player that has bought the items from inventory
  useEffect(() => {
    const loadOwnedItems = async () => {
      const accounts = await web3.eth.getAccounts();
      const fromAddress = accounts[0];
      const ownItems = await GameToken.methods.getItemsByOwner(fromAddress).call({ from: fromAddress });
      setOwnedItems(ownItems);
    };
    loadOwnedItems();
  }, []);

  // get all items in inventory that are in stock
  useEffect(() => {
    const loadInventoryItems = async () => {
      const accounts = await web3.eth.getAccounts();
      const fromAddress = accounts[0];
      const item = await GameToken.methods.getUnpurchasedItems().call({ from: fromAddress });
      setInventoryItems(item);
    };
    loadInventoryItems();
  }, []);

  // buy item button for players from the inventory
  const buyItem = async (itemId) => {
    const idItem = itemId - 1;
    const accounts = await web3.eth.getAccounts();
    const fromAddress = accounts[0];
    await GameToken.methods.buyItem(idItem).send({ from: fromAddress });
  };

  return (
    <div className="menupage columns">
      <div className="tableform column">
        <h1 className="is-size-4">Owned Inventories</h1>
        <table className="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Damage Level</th>
            </tr>
          </thead>
          <tbody>
            {ownedItems.map((ownItems, index) => (
              <tr key={index}>
                <td>{ownItems.id}</td>
                <td>{ownItems.name}</td>
                <td>{ownItems.damage}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="tableform column">
        <h1 className="is-size-4">Buy Inventories</h1>
        <table className="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Damage Level</th>
              <th>Price</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {inventoryItems.map((item, index) => (
              <tr key={index}>
                <td>{item.id}</td>
                <td>{item.name}</td>
                <td>{item.damage}</td>
                <td>{item.price}</td>
                <td>
                  <button className="button is-primary" type="submit" onClick={() => buyItem(item.id)}>
                    Buy
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Inventory;
