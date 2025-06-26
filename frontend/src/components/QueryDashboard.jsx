import React, { useState } from "react";
import axios from "axios";

const queries = [
  { key: "user-portfolio", label: "User Portfolio" },
  { key: "user-transactions", label: "User Transactions" },
  { key: "stock-transactions", label: "Stock Transactions" },
  { key: "top-holders", label: "Top Stock Holders" },
  { key: "transactions-in-range", label: "User Transactions in Date Range" },
];

function QueryDashboard() {
  const [activeQuery, setActiveQuery] = useState(queries[0].key);
  const [formValues, setFormValues] = useState({});
  const [results, setResults] = useState([]);
  const [queryInfo, setQueryInfo] = useState("");
  const [loading, setLoading] = useState(false);

  const handleInputChange = (e) => {
    setFormValues((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleQuerySubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await axios.post(
        `http://localhost:8000/api/${activeQuery}/`,
        formValues
      );
      setQueryInfo(res.data.query_info);
      setResults(res.data.results);
    } catch (err) {
      setQueryInfo("Error: " + (err.response?.data?.error || "Unknown error"));
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  const renderForm = () => {
    switch (activeQuery) {
      case "user-portfolio":
      case "user-transactions":
        return (
          <input
            className="form-control mb-2"
            name="userid"
            placeholder="User ID"
            onChange={handleInputChange}
            required
          />
        );
      case "stock-transactions":
      case "top-holders":
        return (
          <input
            className="form-control mb-2"
            name="stockid"
            placeholder="Stock ID"
            onChange={handleInputChange}
            required
          />
        );
      case "transactions-in-range":
        return (
          <>
            <input
              className="form-control mb-2"
              name="userid"
              placeholder="User ID"
              onChange={handleInputChange}
              required
            />
            <label className="form-label">Start Date</label>
            <input
              type="date"
              className="form-control mb-2"
              name="start_date"
              onChange={handleInputChange}
              required
            />
            <label className="form-label">End Date</label>
            <input
              type="date"
              className="form-control mb-2"
              name="end_date"
              onChange={handleInputChange}
              required
            />
          </>
        );
      default:
        return null;
    }
  };

  return (
    <div className="container mt-4">
      <h3 className="mb-3">🔎 Query Dashboard</h3>

      {/* Tabs */}
      <ul className="nav nav-tabs mb-3">
        {queries.map((q) => (
          <li className="nav-item" key={q.key}>
            <button
              className={`nav-link ${activeQuery === q.key ? "active" : ""}`}
              onClick={() => {
                setActiveQuery(q.key);
                setFormValues({});
                setResults([]);
                setQueryInfo("");
              }}
            >
              {q.label}
            </button>
          </li>
        ))}
      </ul>

      {/* Query Form */}
      <form onSubmit={handleQuerySubmit}>
        {renderForm()}
        <button className="btn btn-primary" disabled={loading}>
          {loading ? (
            <span
              className="spinner-border spinner-border-sm me-2"
              role="status"
            />
          ) : null}
          Run Query
        </button>
      </form>

      {/* Result */}
      {queryInfo && (
        <>
          <hr />
          <h5>{queryInfo}</h5>
          {loading && (
            <div className="text-center my-3">
              <div className="spinner-border text-primary" role="status">
                <span className="visually-hidden">Loading...</span>
              </div>
            </div>
          )}

          {results.length > 0 ? (
            <table className="table table-striped mt-2">
              <thead>
                <tr>
                  {Object.keys(results[0]).map((key) => (
                    <th key={key}>{key}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {results.map((row, i) => (
                  <tr key={i}>
                    {Object.values(row).map((val, j) => (
                      <td key={j}>{val}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>No results found.</p>
          )}
        </>
      )}
    </div>
  );
}

export default QueryDashboard;
