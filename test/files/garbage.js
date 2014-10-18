setTimeout(function() {
  console.timeStamp('testStart');
  generateGarbage()
  console.timeStamp('testEnd');
}, 0);

function generateGarbage() {
  var a = [];
  for(var i = 0; i < 1000000; i++) {
    a.push({i: i});
  }
}