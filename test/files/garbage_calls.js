calls = 100000
garbageItemsPerCall = 10

setTimeout(function() {
  console.timeStamp('testStart');
  generateAll()
  console.timeStamp('testEnd');
}, 0);

function generate() {
    var a = [];
    for(var i = 0; i < garbageItemsPerCall; i++) {
      a.push({i: i});
    }
};

function generateAll() {
  for(var i = 0; i < calls; i++) { generate(); }
}