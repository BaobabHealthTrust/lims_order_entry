function __$(e){return document.getElementById(e)}function init(){if(document.forms.length>0){loadLabels();for(var e=document.forms[0].elements,t=0,n=0;n<e.length;n++)"hidden"!=e[n].type.toLowerCase()&&(navFields.push(e[n]),globalEditControls[e[n].id]=t,globalControlsOrder.push(e[n].id),t++)}}function loadLabels(){for(var e=document.getElementsByTagName("LABEL"),t=0;t<e.length;t++)if(""!=e[t].htmlFor){var n=document.getElementById(e[t].htmlFor);n&&(n.label=e[t])}}function showShield(e){if(void 0==e&&(e=!1),__$("shield"))document.body.removeChild(__$("shield")),null!=spinner&&hideSpinner(),null!=smallSpinner&&hideSmallSpinner();else{var t=document.createElement("div");t.id="shield",t.style.position="absolute",t.style.width="100%",t.style.height="100%",t.style.top="0px",t.style.left="0px",t.style.backgroundColor="rgba(200,200,200,0.5)",t.style.zIndex=110,document.body.appendChild(t),e&&(t.onmousedown=function(){"undefined"!=typeof selectedTest&&(selectedTest=null),"undefined"!=typeof selectedTestSpecimen&&(selectedTestSpecimen=null),__$("popup")&&document.body.removeChild(__$("popup")),__$("shield")&&document.body.removeChild(__$("shield"))})}}function showSpinner(){if(!document.getElementById("spin")){var e=document.createElement("div");e.id="spin",e.style.position="absolute",e.style.top=window.innerHeight/2-80+"px",e.style.left=window.innerWidth/2-25+"px",document.body.appendChild(e);var t={lines:15,length:15,width:8,radius:20,corners:1,rotate:0,color:"#000",speed:1,trail:60,shadow:!1,hwaccel:!1,className:"spinner",zIndex:2e9,top:25,left:25}}var n=document.getElementById("spin");spinner=new Spinner(t).spin(n),showShield()}function hideSpinner(){spinner.stop(),__$("shield")&&document.body.removeChild(__$("shield"))}function showSmallSpinner(){if(!document.getElementById("spin")){var e=document.createElement("div");e.id="spin",e.style.position="absolute",e.style.top=window.innerHeight/2-25+"px",e.style.left=window.innerWidth/2-25+"px",document.body.appendChild(e);var t={lines:15,length:15,width:8,radius:20,corners:1,rotate:0,color:"#000",speed:1,trail:60,shadow:!1,hwaccel:!1,className:"spinner",zIndex:2e9,top:25,left:25}}var n=document.getElementById("spin");smallSpinner=new Spinner(t).spin(n)}function hideSmallSpinner(){smallSpinner.stop()}function __$(e){return document.getElementById(e)}function checkCtrl(e){for(var t=e,n=t.offsetTop,r=t.offsetLeft+1,i=t.offsetWidth,o=t.offsetHeight;t?t.offsetParent!=document.body:!1;)t=t.offsetParent,n+=t?t.offsetTop:0,r+=t?t.offsetLeft:0;return[i,o,n,r]}function showKeyboard(e,t,n,r,i){if(__$(t)){var o=__$(t);if(__$("popupkeyboard")&&void 0==r)o.removeChild(__$("popupkeyboard"));else{if(void 0==e||void 0==o)return;__$("popupkeyboard"),o.innerHTML="";{var l=e;checkCtrl(e)}"undefined"==typeof n&&(n={}),"undefined"==typeof r&&(r=!1),"undefined"==typeof i&&(i=!1),currentCaseUpper=i,currentKeysNumeric=r;var a=document.createElement("div");a.id="popupkeyboard",a.style.margin="auto",a.style.borderRadius="10px",a.style.backgroundColor="rgba(255,255,255,1.0)",o.appendChild(a);var d,s="Done";void 0!=globalEditControls[globalControl.id]&&parseInt(globalEditControls[globalControl.id])<globalControlsOrder.length-1&&(s="Next"),d=currentKeysNumeric?currentKeysQWERTY?[[1,2,3],[4,5,6],[7,8,9],["qwe",":","/",0,".","&larr;",s]]:[[1,2,3],[4,5,6],[7,8,9],["abc",":","/",0,".","&larr;",s]]:currentKeysQWERTY?[["Q","W","E","R","T","Y","U","I","O","P"],["A","S","D","F","G","H","J","K","L","CAP"],["num","Z","X","C","V","B","N","M","abc","&larr;"],[":",".","&nbsp;","/",s]]:[["A","B","C","D","E","F","G","H","I","J"],["K","L","M","N","O","P","Q","R","S","CAP"],["num","T","U","V","W","X","Y","Z","qwe","&larr;"],[":",".","&nbsp;","/",s]];var p={A:!0,B:!0,C:!0,D:!0,E:!0,F:!0,G:!0,H:!0,I:!0,J:!0,K:!0,L:!0,M:!0,N:!0,O:!0,P:!0,Q:!0,R:!0,S:!0,T:!0,U:!0,V:!0,W:!0,X:!0,Y:!0,Z:!0,CAP:!0},u=document.createElement("div");u.style.display="table",u.style.margin="auto",a.appendChild(u);for(var c=0;c<d.length;c++){var m=document.createElement("div");m.style.display="table-row",u.appendChild(m);var h=document.createElement("div");h.style.display="table-cell",h.style.textAlign="center",h.style.padding="0px",m.appendChild(h);for(var y=0;y<d[c].length;y++)if(0!=String(d[c][y]).trim().length){var g=document.createElement("button");g.setAttribute("class",n[d[c][y]]?"button_gray":"button_blue"),g.style.width="40px",g.style.height="60px",g.style.minWidth="30px",g.style.minHeight="40px",g.style.margin="2px",g.style.fontSize="24px",g.style.borderRadius="8px",g.setAttribute("parent",o.id),h.appendChild(g),"num"!=d[c][y]&&"qwe"!=d[c][y]&&"abc"!=d[c][y]&&"Done"!=d[c][y]&&"Next"!=d[c][y]&&FastClick.attach(g),g.id=d[c][y],l&&"."==d[c][y]&&(l.value.trim().match(/\./)||0==l.value.trim().length?g.setAttribute("class","button_gray"):g.setAttribute("class","button_blue")),"hide"==d[c][y]?(g.style.fontSize="12px",g.style.padding="0px"):d[c][y]==s||"num"==d[c][y]||"qwe"==d[c][y]||"abc"==d[c][y]||"cap"==d[c][y]||"CAP"==d[c][y]||"&larr;"==String(d[c][y]).trim()?("num"==d[c][y]||"cap"==d[c][y].toLowerCase().trim()?g.style.paddingLeft="5px":"abc"==d[c][y]||"qwe"==d[c][y].toLowerCase().trim()||"&larr;"==String(d[c][y]).trim()?g.style.paddingLeft="7px":d[c][y]==s&&(g.style.paddingLeft="3px"),g.style.textAlign="center",g.style.width="40px"):"&nbsp;"==String(d[c][y]).trim()&&(g.style.width="260px"),g.innerHTML="cap"==String(d[c][y]).trim().toLowerCase()?"<span style='font-size: 14px;'>"+("cap"==String(d[c][y]).trim().toLowerCase()?currentCaseUpper?String(d[c][y]).toUpperCase():String(d[c][y]).toLowerCase():currentCaseUpper?String(d[c][y]).toLowerCase():String(d[c][y]).toUpperCase()):p[d[c][y]]?"cap"==String(d[c][y]).trim().toLowerCase()?currentCaseUpper?String(d[c][y]).toUpperCase():String(d[c][y]).toLowerCase():currentCaseUpper?String(d[c][y]).toLowerCase():String(d[c][y]).toUpperCase():d[c][y]==s||"num"==d[c][y]||"qwe"==d[c][y]||"abc"==d[c][y]||"cap"==d[c][y]||"CAP"==d[c][y]?"<span style='font-size: 14px;'>"+d[c][y]:d[c][y],n[d[c][y]]?g.setAttribute("class","button_gray"):(g.setAttribute("class","button_blue"),g.addEventListener("touchend",function(){Date.now()},!1),g.addEventListener("click",function(e){e.stopPropagation(),e.preventDefault(),cTime=Date.now();var t="";if(t=this.innerHTML.trim().match(/<span.+>/i)?this.children[0].innerHTML:this.innerHTML,8592==t.trim().charCodeAt(0))l&&(l.value=l.value.trim().substring(0,l.value.trim().length-1));else if("num"==t.trim())currentKeysNumeric=!0,showKeyboard(__$(l.id),this.getAttribute("parent"),n,currentKeysNumeric,currentCaseUpper);else if("abc"==t.trim())currentKeysQWERTY=!1,currentKeysNumeric=!1,showKeyboard(__$(l.id),this.getAttribute("parent"),n,currentKeysNumeric,currentCaseUpper);else if("qwe"==t.trim())currentKeysQWERTY=!0,currentKeysNumeric=!1,showKeyboard(__$(l.id),this.getAttribute("parent"),n,currentKeysNumeric,currentCaseUpper);else if("?"==t.trim())l.value="?";else if("cap"==t.trim().toLowerCase()){currentCaseUpper=!currentCaseUpper;var r=Object.keys(p);if(currentCaseUpper){for(var i=0;i<r.length-1;i++)__$(r[i])&&(__$(r[i]).innerHTML=r[i].toLowerCase());this.innerHTML="<span style='font-size: 14px;'>CAP</span>"}else{for(var i=0;i<r.length-1;i++)__$(r[i])&&(__$(r[i]).innerHTML=r[i].toUpperCase());this.innerHTML="<span style='font-size: 14px;'>cap</span>"}}else if("&nbsp;"==t.trim())l.value+=" ";else{if(t.trim()==s){if(globalControl.value=l.value.trim()+(attachUnits&&l.value.trim().length>0?" "+currentUnits:""),void 0!=globalEditControls[globalControl.id]&&parseInt(globalEditControls[globalControl.id])<globalControlsOrder.length-1){var o=globalControlsOrder[parseInt(globalEditControls[globalControl.id])+1];if("undefined"!=typeof __$(o))return __$("target")&&document.body.removeChild(__$("target")),void setTimeout(function(){captureFreetext(__$(o))},25);__$("target")&&document.body.removeChild(__$("target"))}else __$("target")&&document.body.removeChild(__$("target"));return}"?"==l.value.trim()||"Unknown"==l.value.trim()?l.value=currentCaseUpper?t.trim().toLowerCase():t.trim():overwriteNumber?(l.value=currentCaseUpper?t.trim().toLowerCase():t.trim(),overwriteNumber=!1,l.value.trim().length>0&&__$("CAP")&&!currentCaseUpper&&__$("CAP").click()):(l.value+=currentCaseUpper?t.trim().toLowerCase():t.trim(),l.value.trim().length>0&&__$("CAP")&&!currentCaseUpper&&__$("CAP").click())}n["."]||__$(".").setAttribute("class","button_blue")},!1)),"Unknown"==String(d[c][y]).trim()&&(g.style.fontSize="14px",cell.style.marginTop="-10px")}}}}}function confirmAction(msg,action){"undefined"!=typeof Android?Android.confirmAction(msg,action):confirm(msg)&&eval(action)}function showMsg(e){"undefined"!=typeof Android?Android.showMsg(e):alert(e)}function captureFreetext(e,t,n,r){void 0==t&&(t=!1),attachUnits=t,globalControl=e,currentUnits=globalControl.getAttribute("units"),null==currentUnits&&(currentUnits="");var i=attachUnits?e.value.trim().replace(currentUnits,"").trim():e.value.trim(),o=document.createElement("div");o.id="target",o.style.position="absolute",o.style.left="0px",o.style.top="0px",o.style.height="100%",o.style.width="100%",o.style.backgroundColor="rgba(0,0,0,0.8)",o.style.padding="10px",document.body.appendChild(o),FastClick.attach(__$("target")),__$("target").onclick=function(){__$("target")&&(__$("textArea")&&(globalControl.value=__$("textArea").value.trim()+(attachUnits&&__$("textArea").value.trim().length>0?" "+currentUnits:"")),document.body.removeChild(__$("target")))};var l=document.createElement("table");l.id="myTable",l.style.margin="auto",o.appendChild(l);var a=document.createElement("tbody");l.appendChild(a);var d=document.createElement("tr");a.appendChild(d);var s=document.createElement("tr");a.appendChild(s);var p=document.createElement("td");d.appendChild(p);var u=document.createElement("td");s.appendChild(u);var c=document.createElement("div");c.style.height="150px",c.style.width="100%",p.appendChild(c);var m=document.createElement("div");m.id="keysDiv",m.style.width="100%",u.appendChild(m);var h=document.createElement("textarea");h.id="textArea",h.style.width="95%",h.style.height="80%",h.style.padding="10px",h.style.fontSize="24px",h.style.setProperty("-webkit-user-select","none"),h.style.setProperty("-moz-user-select","none"),h.value=i,"password"==e.type&&h.style.setProperty("-webkit-text-security","circle"),h.onkeydown=function(e){"undefined"==typeof Android&&13==e.keyCode&&__$(navKey)&&__$(navKey).click()},c.appendChild(h),"undefined"==typeof r&&(r=!1),showKeyboard(h,"keysDiv",void 0,n,r),h.focus()}function showMsgForAction(e,t){showShield(!0),__$("shield")||showShield(!0),__$("popup")&&document.body.removeChild(__$("popup"));var n=document.createElement("div");n.id="popup",n.style.position="absolute",n.style.minHeight="200px",n.style.backgroundColor="#fff",n.style.zIndex=120,n.style.border="2px outset #eee",n.style.borderRadius="8px",document.body.appendChild(n);var r=document.createElement("table");r.width="100%",r.style.fontSize="24px",n.appendChild(r);var i=document.createElement("tbody");r.appendChild(i);var o=document.createElement("tr");i.appendChild(o);var l=document.createElement("th");l.innerHTML=void 0==t?"Info":t,l.style.backgroundColor="#345d8c",l.style.color="#fff",l.style.borderTopLeftRadius="8px",l.style.borderTopRightRadius="8px",l.style.border="2px outset #23538a",l.colSpan="2",l.style.padding="5px",o.appendChild(l);var a=document.createElement("tr");i.appendChild(a);var d=document.createElement("td");d.colSpan="2",d.style.padding="5px",d.style.paddingTop="5px",d.style.paddingBottom="5px",d.align="center",d.style.lineHeight="120%",d.style.fontSize="20px",a.appendChild(d),d.innerHTML=e;var s=document.createElement("tr");i.appendChild(s);var p=document.createElement("td");p.align="center",p.style.padding="5px",p.setAttribute("colspan",2),s.appendChild(p);var u=document.createElement("button");if(u.className="button_blue",u.innerHTML="OK",u.style.width="120px",u.style.cursor="pointer",u.style.fontSize="24px",u.style.minHeight="60px",p.appendChild(u),u.onmousedown=function(){__$("popup")&&document.body.removeChild(__$("popup")),__$("shield")&&document.body.removeChild(__$("shield"))},__$("popup")){var c=checkCtrl(__$("popup"));__$("popup").style.top=window.innerHeight/2-c[1]/2+"px",__$("popup").style.left=window.innerWidth/2-c[0]/2+"px"}}function formatTimestamp(timestamp){var time=timestamp.match(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/);if(null!=time){var months=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],month=months[eval(time[2])-1],date=eval(time[3]),result=date+"/"+month+"/"+time[1]+" "+time[4]+":"+time[5]+":"+time[6];return result}return timestamp}var globalEditControls={},globalControlsOrder=[],attachUnits=!1,currentUnits="",navFields=[],spinner,smallSpinner;navigator.sayswho=function(){var e,t=navigator.userAgent,n=t.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i)||[];return/trident/i.test(n[1])?(e=/\brv[ :]+(\d+)/g.exec(t)||[],"IE "+(e[1]||"")):"Chrome"===n[1]&&(e=t.match(/\b(OPR|Edge)\/(\d+)/),null!=e)?e.slice(1).join(" ").replace("OPR","Opera"):(n=n[2]?[n[1],n[2]]:[navigator.appName,navigator.appVersion,"-?"],null!=(e=t.match(/version\/(\d+)/i))&&n.splice(1,1,e[1]),n.join(" "))}();var currentCaseUpper=!1,currentKeysNumeric=!1,currentKeysQWERTY=!0,overwriteNumber=!1,globalControl,cTime;setTimeout(function(){init()},500);