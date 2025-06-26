import { FaRocket, FaSignInAlt, FaSignOutAlt} from "react-icons/fa";
import * as React from "react";
import { Link, useNavigate } from "react-router-dom";


function Navbar() {
    const navigate = useNavigate();
    const userId = localStorage.getItem('userId');
    const username = localStorage.getItem('username'); // Retrieve username from local storage
    const handleLogout = () => {
      localStorage.removeItem('userId');
      localStorage.removeItem('username'); // Remove username from local storage
      navigate('/login');
    };       
    return (
      <div className="flex justify-between items-center p-4 bg-grey shadow-sm">
        <div>
          <h1 className="text-xl font-bold nav-link">TradeWind</h1>
        </div>
        <div className="flex items-center gap-4">
          {userId ? (
            <>
            <li className="flex items-center gap-3 text-white-700 hover:text-blue-600 cursor-pointer">
                <span className="nav-link">Logged in as <strong>{username} ({userId})</strong></span>
              </li>
        <li className="flex items-center gap-3 text-white-700 hover:text-blue-600 cursor-pointer">
        <button className="btn btn-outline-light btn-m ms-2" onClick={handleLogout}>
                  Logout
                </button>
        </li>
          </>
          ) : (
            <>
            <li className="flex items-center gap-3 text-white-700 hover:text-blue-600 cursor-pointer">
          <FaSignInAlt /><Link className="nav-link" to="/login">Login</Link>
        </li>
        <li className="flex items-center gap-3 text-white-700 hover:text-blue-600 cursor-pointer">
          <FaSignOutAlt /><Link className="nav-link" to="/register">Register</Link>
        </li>
          </>
          )}
        </div>
      </div>
    );
  }

export default Navbar;