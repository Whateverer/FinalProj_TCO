<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
  <head>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <meta name="apple-mobile-web-app-capable" content="yes">
  </head>
  <body onload="showMyFace()">
    <style>
      video {
        background-color: #ddd;
        border-radius: 7px;
        margin: 10px 0px 0px 10px;
        width: 320px;
        height: 240px;
      }
      button {
        margin: 5px 0px 0px 10px !important;
        width: 654px;
      }      
    </style>
    <video id="yourVideo" autoplay muted playsinline></video>
    <video id="friendsVideo" autoplay muted playsinline></video>
    <br />
    <button onclick="showFriendsFace()" type="button" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-facetime-video" aria-hidden="true"></span> Call</button>
    <script src="https://www.gstatic.com/firebasejs/4.9.0/firebase.js"></script>
  </body>
 
<script language = "javascript">
//Create an account on Firebase, and use the credentials they give you in place of the following
var config = {
  apiKey: "AIeaS7AvL9f2MvHwVcghtVbGWtOk8AGcRmw6-Rqc",
  authDomain: "webrtc-f0d24.firebaseapp.com",
  databaseURL: "https://webrtc-f0d24.firebaseio.com",
  projectId: "webrtc-f0d24",
  storageBucket: "webrtc-f0d24.appspot.com",
  messagingSenderId: "876347981221",
};
 
 
firebase.initializeApp(config);
 
var database = firebase.database().ref();
var yourVideo = document.getElementById("yourVideo");
var friendsVideo = document.getElementById("friendsVideo");
var yourId = Math.floor(Math.random()*1000000000);
//Create an account on Viagenie (http://numb.viagenie.ca/), and replace {'urls': 'turn:numb.viagenie.ca','credential': 'websitebeaver','username': 'websitebeaver@email.com'} with the information from your account
 
 
//var servers = {'iceServers': [{'urls': 'stun:stun.services.mozilla.com'}, {'urls': 'stun:stun.l.google.com:19302'}, {'urls': 'turn:numb.viagenie.ca','credential': 'beaver','username': 'webrtc.websitebeaver@gmail.com'}]};
//var servers = {'iceServers': [{'urls': 'turn:13.250.13.83:3478?transport=udp','YzYNCouZM1mhqhmseWk6': 'beaver','YzYNCouZM1mhqhmseWk6': 'webrtc.websitebeaver@gmail.com'}]};
 
// ?????? ??????????????? https://gist.github.com/sagivo/3a4b2f2c7ac6e1b5267c2f1f59ac6c6b  ?????? ????????????
var servers = {"urls": ["turn:13.250.13.83:3478?transport=udp"],"username": "YzYNCouZM1mhqhmseWk6","credential": "YzYNCouZM1mhqhmseWk6"}
var pc = new RTCPeerConnection(servers);
pc.onicecandidate = (event => event.candidate?sendMessage(yourId, JSON.stringify({'ice': event.candidate})):console.log("Sent All Ice") );
pc.onaddstream = (event => friendsVideo.srcObject = event.stream);
 
function sendMessage(senderId, data) {
    var msg = database.push({ sender: senderId, message: data });
    msg.remove();
}
 
function readMessage(data) {
    var msg = JSON.parse(data.val().message);
    var sender = data.val().sender;
    if (sender != yourId) {
        if (msg.ice != undefined)
            pc.addIceCandidate(new RTCIceCandidate(msg.ice));
        else if (msg.sdp.type == "offer")
            pc.setRemoteDescription(new RTCSessionDescription(msg.sdp))
              .then(() => pc.createAnswer())
              .then(answer => pc.setLocalDescription(answer))
              .then(() => sendMessage(yourId, JSON.stringify({'sdp': pc.localDescription})));
        else if (msg.sdp.type == "answer")
            pc.setRemoteDescription(new RTCSessionDescription(msg.sdp));
    }
};
 
database.on('child_added', readMessage);
 
function showMyFace() {
  navigator.mediaDevices.getUserMedia({audio:true, video:true})
    .then(stream => yourVideo.srcObject = stream)
    .then(stream => pc.addStream(stream));
}
 
function showFriendsFace() {
  pc.createOffer()
    .then(offer => pc.setLocalDescription(offer) )
    .then(() => sendMessage(yourId, JSON.stringify({'sdp': pc.localDescription})) );
}    
  </script>
</html>
 


