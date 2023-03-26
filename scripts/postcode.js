function getLocationFromPostcode(callback) {
  // First, we need to get the user's input from a form or input field
  const userInput = document.getElementById('postcode-input').value;

  // Then, we can make a request to the postcodes.io API using the user's input
  fetch(`https://api.postcodes.io/postcodes/${userInput}`)
  .then(response => response.json())
  .then(data => {
      if (data.status === 200) {
          // If the request is successful, we can extract the latitude and longitude          
          // The nearestRescue callback expects the position.coords.longitude and position.coords.latitude
          const position = {
            coords : {
              latitude: data.result.latitude,
              longitude: data.result.longitude
            }
          };
          // Now we can use the latitude and longitude to do whatever we need to do with the geolocation data
          console.log(`Latitude: ${position.latitude}, Longitude: ${position.longitude}`);
          callback(position);
      } else {
          // If the request is not successful, we can handle the error
          console.error(`Postcode lookup was not successful for the following reason: ${data.error}`);
      }
  })
  .catch(error => console.error(error));
}
