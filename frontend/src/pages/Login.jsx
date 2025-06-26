import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

function Login() {
  const [userId, setUserId] = useState("");
  const [password, setPassword] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await axios.post("http://localhost:8000/api/login/", {
        userid: userId,
        password: password,
      });

      localStorage.setItem("userId", res.data.userid);
      localStorage.setItem("username", res.data.name);
      navigate("/user-dashboard");
    } catch (err) {
      setErrorMsg(err.response?.data?.error || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mt-5 text-center" style={{ maxWidth: "400px" }}>
      <h3 className="text-3xl font-bold">Login to Tradewind</h3>
      <form onSubmit={handleLogin}>
        <input
          className="form-control mb-2"
          placeholder="User ID"
          value={userId}
          onChange={(e) => setUserId(e.target.value)}
          required
        />
        <input
          type="password"
          className="form-control mb-2"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <button className="btn btn-primary w-100" disabled={loading}>
          {loading ? (
            <span
              className="spinner-border spinner-border-sm me-2"
              role="status"
            />
          ) : null}
          Login
        </button>
      </form>
      {errorMsg && <div className="alert alert-danger mt-3">{errorMsg}</div>}
    </div>
  );
}

export default Login;
