import React, { useEffect, useState } from "react";
import axios from "axios";
import "../assets/css/Sidebar.css";

const Watchlist = () => {
  const userId = localStorage.getItem("userId");
  const [watchlist, setWatchlist] = useState([]);
  const [newSymbol, setNewSymbol] = useState("");

  const fetchWatchlist = async () => {
    try {
      const res = await axios.get(
        `http://localhost:8000/api/watchlist/${userId}/`
      );
      setWatchlist(res.data);
    } catch (err) {
      console.error("Failed to fetch watchlist:", err);
    }
  };

  const addToWatchlist = async () => {
    if (!newSymbol.trim()) return;
    try {
      await axios.post(`http://localhost:8000/api/watchlist/add/`, {
        user_id: userId,
        symbol: newSymbol.toUpperCase(),
      });
      setNewSymbol("");
      fetchWatchlist(); // refresh
    } catch (err) {
      console.error("Failed to add stock:", err);
    }
  };

  const removeFromWatchlist = async (symbol) => {
    try {
      await axios.delete(`http://localhost:8000/api/watchlist/remove/${symbol}/`, {
        data: { user_id: localStorage.getItem("userId") },
      });
      console.log("Stock removed from watchlist:", symbol);      
      fetchWatchlist(); // Refresh list
    } catch (err) {
      alert("Error removing stock from watchlist.");
    }
  };

  useEffect(() => {
    fetchWatchlist();
  }, []);

  return (
    <div className="container mt-3">
      <h4>📈 My Watchlist</h4>

      <div className="input-group my-3" style={{ maxWidth: 300 }}>
        <input
          type="text"
          className="form-control"
          placeholder="Enter Stock Symbol (e.g. TCS)"
          value={newSymbol}
          onChange={(e) => setNewSymbol(e.target.value)}
        />
        <button className="btn btn-primary" onClick={addToWatchlist}>
          Add
        </button>
      </div>

      <table className="table table-bordered">
        <thead>
          <tr>
            <th>Symbol</th>
            <th>Name</th>
            <th>Current Price</th>
          </tr>
        </thead>
        <tbody>
          {watchlist.map((item) => (
            <tr key={item.id}>
              <td>{item.stock.symbol}</td>
              <td>{item.stock.name}</td>
              <td>₹ {item.stock.current_price}
              <button
                className="btn btn-danger btn-sm rem-btn"
                onClick={() => removeFromWatchlist(item.stock.symbol)}
              >
                Remove
              </button>
              </td>              
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Watchlist;
