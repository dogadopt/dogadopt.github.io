function getRescues(callback) {
rescues = []
fetch('../rescues.json')
.then(response => response.json())
.then(data => {
    var rescues = data;
})
.catch(error => {
    console.error('Error reading data:', error);
});