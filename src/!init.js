


var Firebase = require("firebase")
var myFirebaseRef = new Firebase('https://dazzle-staging.firebaseio-demo.com/');

myFirebaseRef.child("location/city").on("value", function(snapshot) {
  console.log(snapshot.val());  // Alerts "San Francisco"
});
