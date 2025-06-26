import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

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
    <nav className="navbar navbar-expand-lg navbar-dark bg-primary px-4">
      <span className="navbar-brand"><Link className='nav-link' to='/'>📈 Tradewind</Link></span>

      <div className="collapse navbar-collapse">
        <ul className="navbar-nav ms-auto">
        <li className="nav-item">
  <Link className="nav-link" to="/query-dashboard">Query Dashboard</Link>
</li>
          {userId ? (
            <>
              <li className="nav-item">
                <span className="nav-link">Logged in as <strong>{username} ({userId})</strong></span>
              </li>
              <li className="nav-item">
                <Link className="nav-link" to="/user-dashboard">User Dashboard</Link>
              </li>
              <li className="nav-item">
                <button className="btn btn-outline-light btn-sm ms-2" onClick={handleLogout}>
                  Logout
                </button>
              </li>
            </>
          ) : (
            <>
              <li className="nav-item">
                <Link className="nav-link" to="/login">Login</Link>
              </li>
              <li className="nav-item">
                <Link className="nav-link" to="/register">Register</Link>
              </li>
            </>
          )}
        </ul>
      </div>
    </nav>
  );
}

export default Navbar;
