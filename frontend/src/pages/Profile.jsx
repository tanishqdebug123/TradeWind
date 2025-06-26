import React, { useEffect, useState } from "react";
import axios from "axios";
import { Eye, EyeOff } from "lucide-react";

const Profile = () => {
  const userId = localStorage.getItem("userId");
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showPassword, setShowPassword] = useState(false);

  const fetchProfile = async () => {
    try {
      const res = await axios.post("http://localhost:8000/api/profile/", {
        userid: userId,
      });
      setProfile(res.data);
    } catch (err) {
      console.error("Failed to fetch profile:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  if (loading) return <p>Loading profile...</p>;

  if (!profile) return <p>Profile not found.</p>;

  return (
    <div className="container mt-3" style={{ maxWidth: 600 }}>
      <h4>👤 My Profile</h4>
      <table className="table table-striped mt-3">
        <tbody>
          <tr>
            <th>User ID</th>
            <td>{profile.userid}</td>
          </tr>
          <tr>
            <th>Name</th>
            <td>{profile.name}</td>
          </tr>
          <tr>
            <th>Email</th>
            <td>{profile.email}</td>
          </tr>
          <tr>
            <th>Password (Hashed)</th>
            <td>
              <div className="d-flex align-items-center justify-content-between">
                <code style={{ wordBreak: "break-all" }}>
                  {showPassword ? profile.password : "•".repeat(20)}
                </code>
                <button
                  className="btn btn-sm btn-outline-secondary ms-2"
                  onClick={() => setShowPassword(!showPassword)}
                  title={showPassword ? "Hide password" : "Show password"}
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </td>
          </tr>
          <tr>
            <th>Virtual Balance</th>
            <td>₹ {profile.virtual_balance.toFixed(2)}</td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};

export default Profile;
