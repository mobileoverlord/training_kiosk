// for phoenix_html support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * https://raw.githubusercontent.com/phoenixframework/phoenix_html/v2.10.0/priv/static/phoenix_html.js

var socket = null;
var channel = null;

socket = new Phoenix.Socket("/socket");
socket.connect();

channel = socket.channel("home:lobby")
channel.join()
    .receive("ok", resp => 
      { console.log("Joined successfully", resp) })
    .receive("error", resp => 
      { console.log("Unable to join", resp) })

var brightnessSlider = document.getElementById("brightnessRange");

channel.on("brightness", payload => {
  brightnessSlider.value = payload.value;
})

brightnessSlider.oninput = function() {
  channel.push("brightness", {value: parseInt(this.value)})
  console.log("Brightness:" + this.value);
}

var canvas = document.getElementById("draw-canvas");
var ctx = canvas.getContext("2d");
function drawLine(from, to) {
  // Send a message to draw a line (we'll draw when we receive it)
  channel.push("drawLine", {line: [from, to]})
}
// Draw whatever we receive
channel.on("drawLine", payload => {
  var from = payload.line[0];
  var to = payload.line[1];
  ctx.moveTo(from.x, from.y);	
  ctx.lineTo(to.x, to.y);	 
  ctx.stroke();	  
})

var lastPoints = {};
function moveTo(identifier, point) {
  lastPoints[identifier] = point;
}
function lineTo(identifier, point) {
  if (lastPoints[identifier]) {
    drawLine(lastPoints[identifier], point);
  }
  lastPoints[identifier] = point;
}
function getPos(client) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: client.clientX - rect.left,
    y: client.clientY - rect.top
  };
}
function haltEventBefore(handler) {
  return function(event) {
    event.stopPropagation();
    event.preventDefault();
    handler(event);
  }
}
// ----------------
//  Touch Handling
// ----------------
var mouseDown = false;
canvas.addEventListener('mousedown', haltEventBefore(function(event) {
  mouseDown = true;
  moveTo("mouse", getPos(event));
}));
document.documentElement.addEventListener('mouseup', function(event) {
  mouseDown = false;
});
canvas.addEventListener('mousemove', haltEventBefore(function(event) {
  if (!mouseDown) return;
  lineTo("mouse", getPos(event));
}));
canvas.addEventListener('mouseleave', haltEventBefore(function(event) {
  if (!mouseDown) return;
  lineTo("mouse", getPos(event));
}));
canvas.addEventListener('mouseenter', haltEventBefore(function(event) {
  if (!mouseDown) return;
  moveTo("mouse", getPos(event));
}));
// ----------------
//  Touch Handling
// ----------------
function handleTouchesWith(func) {
  return haltEventBefore(function(event) {
    for (var i = 0; i < event.changedTouches.length; i++) {
      var touch = event.changedTouches[i];
      func(touch.identifier, getPos(touch));
    }
  });
};
canvas.addEventListener('touchstart',  handleTouchesWith(moveTo));
canvas.addEventListener('touchmove',   handleTouchesWith(lineTo));
canvas.addEventListener('touchend',    handleTouchesWith(lineTo));
canvas.addEventListener('touchcancel', handleTouchesWith(moveTo));
