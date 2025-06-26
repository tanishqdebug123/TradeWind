import React, { useState } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../assets/css/Sidebar.css';

const Sidebar = ({ activeTab, onTabChange }) => {
  const [isOpen, setIsOpen] = useState(true);

  const toggleSidebar = () => setIsOpen(!isOpen);

  return (
    <div className={`d-flex flex-column bg-light sidebar ${isOpen ? 'expanded' : 'collapsed'}`}>
      <button className="btn btn-outline-primary m-2" onClick={toggleSidebar}>
        {isOpen ? '☰' : '☰'}
      </button>

      {isOpen && (
        <ul className="nav flex-column mt-3">
          <li className="nav-item">
            <button className={`btn nav-link text-3xl ${activeTab === "profile" ? "active" : "inactive"}`} onClick={() => onTabChange("profile")}>
            👤 Profile
            </button>
          </li>
          <li className="nav-item">
            <button className={`btn nav-link text-3xl ${activeTab === "watchlist" ? "active" : "inactive"}`} onClick={() => onTabChange("watchlist")}>
              📈 Watchlist
            </button>
          </li>
          <li className="nav-item">
            <button className={`btn nav-link text-3xl ${activeTab === "orders" ? "active" : "inactive"}`} onClick={() => onTabChange('orders')}>
              💼 Orders
            </button>
          </li>
          <li className="nav-item">
            <button className={`btn nav-link text-3xl ${activeTab === "portfolio" ? "active" : "inactive"}`} onClick={() => onTabChange('portfolio')}>
              📊 Portfolio
            </button>
          </li>
          {/*}
          <li className="nav-item">
            <button className={`btn nav-link text-3xl ${activeTab === "placeOrder" ? "active" : "inactive"}`} onClick={() => onTabChange('placeOrder')}>
              🛒 Place Order
            </button>
          </li>
          */}
        </ul>
      )}
    </div>
  );
};

export default Sidebar;
