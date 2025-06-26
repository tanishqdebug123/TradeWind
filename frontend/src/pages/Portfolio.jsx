import React, { useEffect, useState } from "react";
import axios from "axios";

const Portfolio = () => {
  const [portfolio, setPortfolio] = useState([]);
  const [loading, setLoading] = useState(true);
  const [queryInfo, setQueryInfo] = useState("");

  useEffect(() => {
    const fetchPortfolio = async () => {
      const userId = localStorage.getItem("userId");
      if (!userId) {
        setQueryInfo("User not logged in.");
        setLoading(false);
        return;
      }

      try {
        const res = await axios.post("http://localhost:8000/api/user-portfolio/", {
          userid: userId,
        });
        setQueryInfo(res.data.query_info);
        setPortfolio(res.data.results);
      } catch (err) {
        setQueryInfo("Error: " + (err.response?.data?.error || "Unknown error"));
        setPortfolio([]);
      } finally {
        setLoading(false);
      }
    };

    fetchPortfolio();
  }, []);

  return (
    <div className="p-3">
      <h3>📈 Your Portfolio</h3>

      {loading ? (
        <div className="text-center my-3">
          <div className="spinner-border text-primary" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
        </div>
      ) : (
        <>
          <h5>{queryInfo}</h5>
          {portfolio.length > 0 ? (
            <table className="table table-striped mt-2">
              <thead>
                <tr>
                  {Object.keys(portfolio[0]).map((key) => (
                    <th key={key}>{key}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {portfolio.map((row, i) => (
                  <tr key={i}>
                    {Object.values(row).map((val, j) => (
                      <td key={j}>{val}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>No portfolio data found.</p>
          )}
        </>
      )}
    </div>
  );
};

export default Portfolio;
