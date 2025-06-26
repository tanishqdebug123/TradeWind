import React, { useEffect, useState } from "react";
import axios from "axios";

const Orders = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [queryInfo, setQueryInfo] = useState("");

  useEffect(() => {
    const fetchTransactions = async () => {
      const userId = localStorage.getItem("userId");
      if (!userId) {
        setQueryInfo("User not logged in.");
        setLoading(false);
        return;
      }

      try {
        const res = await axios.post("http://localhost:8000/api/user-transactions/", {
          userid: userId,
        });
        setQueryInfo(res.data.query_info);
        setTransactions(res.data.results);
      } catch (err) {
        setQueryInfo("Error: " + (err.response?.data?.error || "Unknown error"));
        setTransactions([]);
      } finally {
        setLoading(false);
      }
    };

    fetchTransactions();
  }, []);

  return (
    <div className="p-3">
      <h3>📄 Order History</h3>

      {loading ? (
        <div className="text-center my-3">
          <div className="spinner-border text-primary" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
        </div>
      ) : (
        <>
          <h5>{queryInfo}</h5>
          {transactions.length > 0 ? (
            <table className="table table-striped mt-2">
              <thead>
                <tr>
                  {Object.keys(transactions[0]).map((key) => (
                    <th key={key}>{key}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {transactions.map((row, i) => (
                  <tr key={i}>
                    {Object.values(row).map((val, j) => (
                      <td key={j}>{val}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>No transactions found.</p>
          )}
        </>
      )}
    </div>
  );
};

export default Orders;