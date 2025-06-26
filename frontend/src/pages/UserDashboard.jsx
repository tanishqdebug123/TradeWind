import React, { useState } from 'react';
import Sidebar from '../components/Sidebar';
import Watchlist from "./Watchlist";
import Orders from "./Orders";
import Portfolio from "./Portfolio";
import Profile from './Profile';
//import PlaceOrder from "./PlaceOrder";

const UserDashboard = () => {
  const [activeTab, setActiveTab] = useState('profile');

  const renderPage = () => {
    switch (activeTab) {
      case 'profile':
        return <Profile />;      
      case 'watchlist':
        return <Watchlist />;
      case 'orders':
        return <Orders />;
      case 'portfolio':
        return <Portfolio />;
      /*case 'placeOrder':
        return <PlaceOrder />;*/
      default:
        return <Profile />;
    }
  };

  return (
    <div className="d-flex">
      <Sidebar activeTab={activeTab} onTabChange={setActiveTab} />
      <div className="flex-grow-1 p-3">{renderPage()}</div>
    </div>
  );
};

export default UserDashboard;
