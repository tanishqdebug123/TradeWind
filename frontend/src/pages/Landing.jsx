import React from 'react';
import { useNavigate } from 'react-router-dom';

function Landing() {
  const navigate = useNavigate();
  return (
    <div className="container mt-5 text-center">
      <h1 className='text-3xl font-bold'>📈 Welcome to Tradewind</h1>
      <p className="lead mt-3">
        Tradewind is a simplified trading platform that lets you explore stocks, view portfolios, and run insightful queries on trading activity.
      </p>
      <div className="d-flex justify-content-center gap-3 mt-4">
      <button className="btn btn-primary text-2xl font-bold" style={{ marginRight: "20px", width: "85px", height: "45px"}} onClick={() => navigate('/login')}>Login</button>
      <button className="btn btn-outline-primary text-xl font-bold" style={{ width: "90px", height: "45px"}} onClick={() => navigate('/register')}>Register</button>
      </div>
    </div>
  );

}

export default Landing;
