import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const PlaceOrder = () => {
  const [userId, setUserId] = useState('');
  const [symbol, setSymbol] = useState('');
  const [orderType, setOrderType] = useState('BUY');
  const [quantity, setQuantity] = useState(0);
  const [price, setPrice] = useState(0);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const storedId = localStorage.getItem('userId');
    if (storedId) {
      setUserId(storedId);
    } else {
      setError('User not logged in. Please log in again.');
    }
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage('');
    setError('');

    try {
      const payload = {
        user_id: userId,
        symbol: symbol.toUpperCase(),
        order_type: orderType,
        quantity: quantity,
        price: price,
      };

      const response = await axios.post('http://localhost:8000/api/place_order/', payload);

      if (response.status === 200) {
        setMessage('Order placed successfully!');
        setTimeout(() => navigate('/dashboard'), 2000);
      }
    } catch (err) {
      if (err.response && err.response.data.error) {
        setError(err.response.data.error);
      } else {
        setError('An error occurred while placing the order.');
      }
    }
  };

  return (
    <div className="place-order-container">
      <h2>Place Order</h2>

      {error && <p className="error-message">{error}</p>}
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Stock Symbol</label>
          <input
            type="text"
            value={symbol}
            onChange={(e) => setSymbol(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Order Type</label>
          <select
            value={orderType}
            onChange={(e) => setOrderType(e.target.value)}
            required
          >
            <option value="BUY">Buy</option>
            <option value="SELL">Sell</option>
          </select>
        </div>

        <div className="form-group">
          <label>Quantity</label>
          <input
            type="number"
            value={quantity}
            onChange={(e) => setQuantity(Number(e.target.value))}
            min="1"
            required
          />
        </div>

        <div className="form-group">
          <label>Price</label>
          <input
            type="number"
            value={price}
            onChange={(e) => setPrice(Number(e.target.value))}
            step="0.01"
            required
          />
        </div>

        <button type="submit" disabled={!userId}>Place Order</button>
      </form>

      {message && <p className="success-message">{message}</p>}
    </div>
  );
};

export default PlaceOrder;