const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
const port = 4000; // Ensure this matches the port you're using

// Enable CORS for all routes
app.use(cors());

app.get('/nearby-schools', async (req, res) => {
  const { lat, lng, radius, type, key } = req.query;

  // Check if all required parameters are present
  if (!lat || !lng || !radius || !type || !key) {
    console.error('Invalid request: Missing required parameters.');
    return res.status(400).send('Invalid request: Missing required parameters.');
  }

  console.log(`Received request: lat=${lat}, lng=${lng}, radius=${radius}, type=${type}, key=${key}`);

  try {
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', {
      params: {
        location: `${lat},${lng}`,
        radius,
        type,
        key
      }
    });

    if (response.data.status !== 'OK') {
      console.error(`Google API error: ${response.data.status}`);
      return res.status(500).send(`Error from Google Places API: ${response.data.status}`);
    }

    console.log(`Google API response: ${JSON.stringify(response.data)}`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching data from Google Places API:', error);
    res.status(500).send('Error fetching data from Google Places API');
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
