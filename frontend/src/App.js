import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css'; // We'll create this CSS file

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

function App() {
  const [destinations, setDestinations] = useState([]);
  const [country, setCountry] = useState('');
  const [selectedVacationType, setSelectedVacationType] = useState(null);
  const [showForm, setShowForm] = useState(false);

  const vacationTypes = [
    {
      id: 'tropical',
      icon: '🌴',
      title: 'Tropical Paradise',
      description: 'Beaches, sun, and relaxation'
    },
    {
      id: 'mountain',
      icon: '🏔️',
      title: 'Mountain Adventure', 
      description: 'Hiking, skiing, and fresh air'
    },
    {
      id: 'cultural',
      icon: '🏛️',
      title: 'Cultural Experience',
      description: 'Museums, history, and local cuisine'
    }
  ];

  useEffect(() => {
    fetchDestinations();
  }, []);

  const fetchDestinations = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/destinations`);
      setDestinations(response.data);
    } catch (error) {
      console.error('Error fetching destinations:', error);
    }
  };

  const handleVacationSelect = (type) => {
    setSelectedVacationType(type);
    setShowForm(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${API_URL}/api/destinations`, { 
        country,
        vacationType: selectedVacationType 
      });
      setCountry('');
      fetchDestinations();
    } catch (error) {
      console.error('Error adding destination:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`${API_URL}/api/destinations/${id}`);
      fetchDestinations();
    } catch (error) {
      console.error('Error deleting destination:', error);
    }
  };

  const getVacationTypeEmoji = (type) => {
    const typeMap = {
      tropical: '🌴',
      mountain: '🏔️', 
      cultural: '🏛️'
    };
    return typeMap[type] || '✈️';
  };

  return (
    <div className="app">
      <div className="container">
        {/* Header */}
        <div className="header">
          <div className="logo-container">
            <div className="logo">🏖️</div>
            <h1 className="title">Dream Vacation Planner</h1>
          </div>
          <p className="subtitle">Plan your perfect getaway!</p>
        </div>

        {/* Vacation Type Selection */}
        <div className="vacation-grid">
          {vacationTypes.map((type) => (
            <div
              key={type.id}
              className={`vacation-card ${selectedVacationType === type.id ? 'selected' : ''}`}
              onClick={() => handleVacationSelect(type.id)}
            >
              <span className="vacation-icon">{type.icon}</span>
              <h3 className="vacation-title">{type.title}</h3>
              <p className="vacation-description">{type.description}</p>
            </div>
          ))}
        </div>

        {/* Destination Form */}
        {showForm && (
          <div className="destination-form">
            <h3>Add Your Dream Destination</h3>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="countryInput" className="form-label">
                  Enter a country or destination:
                </label>
                <input
                  id="countryInput"
                  type="text"
                  value={country}
                  onChange={(e) => setCountry(e.target.value)}
                  placeholder="e.g., Maldives, Switzerland, Japan"
                  className="form-input"
                  required
                />
              </div>
              <button type="submit" className="btn-primary">
                Add Destination
              </button>
            </form>

            {/* Destinations List */}
            {destinations.length > 0 && (
              <div className="destinations-list">
                <h4>Your Dream Destinations:</h4>
                <div className="destinations-grid">
                  {destinations.map((dest) => (
                    <div key={dest.id} className="destination-item">
                      <div className="destination-header">
                        <span className="destination-emoji">
                          {getVacationTypeEmoji(dest.vacationType)}
                        </span>
                        <h3 className="destination-country">{dest.country}</h3>
                      </div>
                      <div className="destination-details">
                        <p><strong>Capital:</strong> {dest.capital}</p>
                        <p><strong>Population:</strong> {dest.population?.toLocaleString()}</p>
                        <p><strong>Region:</strong> {dest.region}</p>
                        {dest.vacationType && (
                          <p><strong>Type:</strong> {dest.vacationType}</p>
                        )}
                      </div>
                      <button 
                        onClick={() => handleDelete(dest.id)}
                        className="btn-delete"
                      >
                        Remove
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Server Status */}
        <div className="status-section">
          <div className="status-title">Server running on EC2 instance!</div>
          <div className="deployment-status">
            <span className="status-indicator"></span>
            <span>Deployment successful ✅</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;