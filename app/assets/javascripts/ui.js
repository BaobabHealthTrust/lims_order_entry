var globalEditControls = {};

var globalControlsOrder = [];

var attachUnits = false;

var currentUnits = "";

var navFields = [];

function __$(id) {
    return document.getElementById(id);
}

function init() {

    if (document.forms.length > 0) {
        loadLabels();

        var fields = document.forms[0].elements;

        var j = 0;
        for (var i = 0; i < fields.length; i++) {

            if (fields[i].type.toLowerCase() != "hidden") {

                navFields.push(fields[i]);

                globalEditControls[fields[i].id] = j;

                globalControlsOrder.push(fields[i].id);

                j++;

            }

        }

    }

}

function loadLabels() {
    var labels = document.getElementsByTagName('LABEL');
    for (var i = 0; i < labels.length; i++) {
        if (labels[i].htmlFor != '') {
            var elem = document.getElementById(labels[i].htmlFor);
            if (elem)
                elem.label = labels[i];
        }
    }
}

function showShield(clickCloses) {

    if (clickCloses == undefined) {

        clickCloses = false;

    }

    if (__$("shield")) {

        document.body.removeChild(__$("shield"));

        hideSpinner();

        hideSmallSpinner();

    } else {

        var shield = document.createElement("div");
        shield.id = "shield";
        shield.style.position = "absolute";
        shield.style.width = "100%";
        shield.style.height = "100%";
        shield.style.top = "0px";
        shield.style.left = "0px";
        shield.style.backgroundColor = "rgba(200,200,200,0.5)";
        shield.style.zIndex = 110;

        document.body.appendChild(shield);

        if (clickCloses) {

            shield.onmousedown = function () {

                if (typeof(selectedTest) != "undefined")
                    selectedTest = null;

                if (typeof(selectedTestSpecimen) != "undefined")
                    selectedTestSpecimen = null;

                if (__$("popup")) {

                    document.body.removeChild(__$("popup"));

                }

                if (__$("shield")) {

                    document.body.removeChild(__$("shield"));

                }

            }

        }
    }

}


var spinner;

function showSpinner() {

    if (!document.getElementById('spin')) {
        var div = document.createElement("div");
        div.id = "spin";
        div.style.position = "absolute";
        div.style.top = ((window.innerHeight / 2) - 80) + "px";
        div.style.left = ((window.innerWidth / 2) - 25) + "px";

        document.body.appendChild(div);
        var opts = {
            lines: 15, // The number of lines to draw
            length: 15, // The length of each line
            width: 8, // The line thickness
            radius: 20, // The radius of the inner circle
            corners: 1, // Corner roundness (0..1)
            rotate: 0, // The rotation offset
            color: '#000', // #rgb or #rrggbb
            speed: 1, // Rounds per second
            trail: 60, // Afterglow percentage
            shadow: false, // Whether to render a shadow
            hwaccel: false, // Whether to use hardware acceleration
            className: 'spinner', // The CSS class to assign to the spinner
            zIndex: 2e9, // The z-index (defaults to 2000000000)
            top: 25, // Top position relative to parent in px
            left: 25 // Left position relative to parent in px
        };
    }

    var target = document.getElementById('spin');
    spinner = new Spinner(opts).spin(target);

    showShield();

}

function hideSpinner() {

    spinner.stop();

    if (__$("shield")) {

        document.body.removeChild(__$("shield"));

    }

}

var smallSpinner;

function showSmallSpinner() {

    if (!document.getElementById('spin')) {
        var div = document.createElement("div");
        div.id = "spin";
        div.style.position = "absolute";
        div.style.top = ((window.innerHeight / 2) - 25) + "px";
        div.style.left = ((window.innerWidth / 2) - 25) + "px";

        document.body.appendChild(div);
        var opts = {
            lines: 15, // The number of lines to draw
            length: 15, // The length of each line
            width: 8, // The line thickness
            radius: 20, // The radius of the inner circle
            corners: 1, // Corner roundness (0..1)
            rotate: 0, // The rotation offset
            color: '#000', // #rgb or #rrggbb
            speed: 1, // Rounds per second
            trail: 60, // Afterglow percentage
            shadow: false, // Whether to render a shadow
            hwaccel: false, // Whether to use hardware acceleration
            className: 'spinner', // The CSS class to assign to the spinner
            zIndex: 2e9, // The z-index (defaults to 2000000000)
            top: 25, // Top position relative to parent in px
            left: 25 // Left position relative to parent in px
        };
    }

    var target = document.getElementById('spin');
    smallSpinner = new Spinner(opts).spin(target);

}

function hideSmallSpinner() {

    smallSpinner.stop();

}

navigator.sayswho = (function () {
    var ua = navigator.userAgent, tem,
        M = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
    if (/trident/i.test(M[1])) {
        tem = /\brv[ :]+(\d+)/g.exec(ua) || [];
        return 'IE ' + (tem[1] || '');
    }
    if (M[1] === 'Chrome') {
        tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
        if (tem != null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
    }
    M = M[2] ? [M[1], M[2]] : [navigator.appName, navigator.appVersion, '-?'];
    if ((tem = ua.match(/version\/(\d+)/i)) != null) M.splice(1, 1, tem[1]);
    return M.join(' ');
})();

var currentCaseUpper = false;
var currentKeysNumeric = false;
var currentKeysQWERTY = true;

var overwriteNumber = false;

var globalControl;

var cTime;

function __$(id) {
    return document.getElementById(id);
}

function checkCtrl(obj) {
    var o = obj;
    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while ((o ? (o.offsetParent != document.body) : false)) {
        o = o.offsetParent;
        t += (o ? o.offsetTop : 0);
        l += (o ? o.offsetLeft : 0);
    }
    return [w, h, t, l];
}

function showKeyboard(ctrl, container_id, disabled, numbers, caps) {

    if (!__$(container_id)) {
        return;
    }

    var container = __$(container_id);

    if (__$('popupkeyboard') && numbers == undefined) {

        container.removeChild(__$('popupkeyboard'));

    } else {

        if (ctrl == undefined || container == undefined)
            return;

        if (__$('popupkeyboard')) {
            // container.removeChild(__$('popupkeyboard'));
        }

        container.innerHTML = "";

        /*if (!__$("main")) {
         var main = document.createElement("div");
         main.id = "main";

         container.appendChild(main);
         }*/

        var target = ctrl;

        var pos = checkCtrl(ctrl);

        if (typeof(disabled) == 'undefined') disabled = {};

        if (typeof(numbers) == 'undefined') numbers = false;

        if (typeof(caps) == 'undefined') caps = false;

        currentCaseUpper = caps;

        currentKeysNumeric = numbers;

        var div = document.createElement('div');
        div.id = 'popupkeyboard';
        div.style.margin = 'auto';
        div.style.borderRadius = '10px';
        div.style.backgroundColor = 'rgba(255,255,255,1.0)';

        container.appendChild(div);

        var keys;

        var navKey = "Done";

        if (globalEditControls[globalControl.id] != undefined && parseInt(globalEditControls[globalControl.id]) < globalControlsOrder.length - 1) {

            navKey = "Next";

        }

        if (currentKeysNumeric) {

            if (currentKeysQWERTY) {

                keys = [
                    [1, 2, 3],
                    [4, 5, 6],
                    [7, 8, 9],
                    ['qwe', ':', '/', 0, '.', '&larr;', navKey]
                ];

            } else {

                keys = [
                    [1, 2, 3],
                    [4, 5, 6],
                    [7, 8, 9],
                    ['abc', ':', '/', 0, '.', '&larr;', navKey]
                ];

            }

        } else {

            if (currentKeysQWERTY) {

                keys = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L", "CAP"],
                    ["num", "Z", "X", "C", "V", "B", "N", "M", "abc", '&larr;'],
                    [":", ".", '&nbsp;', "/", navKey]
                ];

            } else {

                keys = [
                    ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"],
                    ["K", "L", "M", "N", "O", "P", "Q", "R", "S", "CAP"],
                    ["num", "T", "U", "V", "W", "X", "Y", "Z", "qwe", '&larr;'],
                    [":", ".", '&nbsp;', "/", navKey]
                ];

            }

        }

        var letters = {"A": true, "B": true, "C": true, "D": true, "E": true, "F": true, "G": true, "H": true,
            "I": true, "J": true, "K": true, "L": true, "M": true, "N": true, "O": true, "P": true, "Q": true,
            "R": true, "S": true, "T": true, "U": true, "V": true, "W": true, "X": true, "Y": true, "Z": true, "CAP": true};

        var table = document.createElement('div');
        table.style.display = 'table';
        table.style.margin = 'auto';

        div.appendChild(table);

        for (var i = 0; i < keys.length; i++) {
            var row = document.createElement('div');
            row.style.display = 'table-row';

            table.appendChild(row);

            var mainCell = document.createElement('div');
            mainCell.style.display = 'table-cell';
            mainCell.style.textAlign = "center";
            mainCell.style.padding = "0px";

            row.appendChild(mainCell);

            for (var j = 0; j < keys[i].length; j++) {

                if (String(keys[i][j]).trim().length == 0) {
                    // cell.innerHTML = "&nbsp;";

                    continue;
                }

                var button = document.createElement('button');
                button.setAttribute('class', (disabled[keys[i][j]] ? 'button_gray' : 'button_blue'));
                button.style.width = '40px';
                button.style.height = '60px';
                button.style.minWidth = '30px';
                button.style.minHeight = '40px';
                button.style.margin = '2px';
                button.style.fontSize = "24px";
                button.style.borderRadius = "8px";
                button.setAttribute("parent", container.id);

                mainCell.appendChild(button);

                if (keys[i][j] != "num" && keys[i][j] != "qwe" && keys[i][j] != "abc" && keys[i][j] != "Done" && keys[i][j] != "Next") {

                    FastClick.attach(button);

                }

                button.id = keys[i][j];

                if (target && keys[i][j] == '.') {
                    if (target.value.trim().match(/\./) || target.value.trim().length == 0) {
                        button.setAttribute('class', 'button_gray');
                    } else {
                        button.setAttribute('class', 'button_blue');
                    }
                }

                if (keys[i][j] == "hide") {

                    button.style.fontSize = "12px";
                    button.style.padding = "0px";

                } else if (keys[i][j] == navKey || keys[i][j] == "num" || keys[i][j] == "qwe" || keys[i][j] == "abc" || keys[i][j] == "cap" || keys[i][j] == "CAP" || String(keys[i][j]).trim() == "&larr;") {

                    if (keys[i][j] == "num" || keys[i][j].toLowerCase().trim() == "cap") {

                        button.style.paddingLeft = "5px";

                    } else if (keys[i][j] == "abc" || keys[i][j].toLowerCase().trim() == "qwe" || String(keys[i][j]).trim() == "&larr;") {

                        button.style.paddingLeft = "7px";

                    } else if (keys[i][j] == navKey) {

                        button.style.paddingLeft = "3px";

                    }

                    button.style.textAlign = "center";

                    button.style.width = "40px";

                } else if (String(keys[i][j]).trim() == "&nbsp;") {

                    button.style.width = "260px";

                }

                if (String(keys[i][j]).trim().toLowerCase() == "cap") {

                    button.innerHTML = "<span style='font-size: 14px;'>" + (String(keys[i][j]).trim().toLowerCase() ==
                        "cap" ? (!currentCaseUpper ? String(keys[i][j]).toLowerCase() :
                        String(keys[i][j]).toUpperCase()) : (!currentCaseUpper ?
                        String(keys[i][j]).toUpperCase() : String(keys[i][j]).toLowerCase())) + "";

                } else if (letters[keys[i][j]]) {

                    button.innerHTML = (String(keys[i][j]).trim().toLowerCase() == "cap" ? (!currentCaseUpper ? String(keys[i][j]).toLowerCase() : String(keys[i][j]).toUpperCase()) : (!currentCaseUpper ? String(keys[i][j]).toUpperCase() : String(keys[i][j]).toLowerCase()));

                } else if (keys[i][j] == navKey || keys[i][j] == "num" || keys[i][j] == "qwe" || keys[i][j] == "abc" || keys[i][j] == "cap" || keys[i][j] == "CAP") {

                    button.innerHTML = "<span style='font-size: 14px;'>" + keys[i][j] + "";

                } else {

                    button.innerHTML = keys[i][j];

                }

                if (disabled[keys[i][j]]) {
                    button.setAttribute('class', 'button_gray');
                } else {
                    button.setAttribute('class', 'button_blue');

                    button.addEventListener('touchend', function (event) {

                        var teTime = Date.now();

                    }, false);

                    button.addEventListener('click', function (event) {

                        event.stopPropagation();

                        event.preventDefault();

                        cTime = Date.now();

                        var label = "";

                        if (this.innerHTML.trim().match(/<span.+>/i)) {

                            label = this.children[0].innerHTML;

                        } else {

                            label = this.innerHTML;

                        }

                        if (label.trim().charCodeAt(0) == 8592) {
                            if (target) {
                                target.value = target.value.trim().substring(0, (target.value.trim().length - 1));
                            }

                        } else if (label.trim() == 'num') {

                            currentKeysNumeric = true;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (label.trim() == 'abc') {

                            currentKeysQWERTY = false;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (label.trim() == 'qwe') {

                            currentKeysQWERTY = true;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (label.trim() == '?') {

                            target.value = "?";

                        } else if (label.trim().toLowerCase() == 'cap') {
                            currentCaseUpper = !currentCaseUpper;

                            var keys = Object.keys(letters);

                            if (!currentCaseUpper) {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toUpperCase();
                                    }
                                }

                                this.innerHTML = "<span style='font-size: 14px;'>" + "cap" + "</span>";

                            } else {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toLowerCase();
                                    }
                                }

                                this.innerHTML = "<span style='font-size: 14px;'>" + "CAP" + "</span>";

                            }

                        } else if (label.trim() == '&nbsp;') {

                            target.value += " ";

                        } else if (label.trim() == navKey) {

                            globalControl.value = target.value.trim() + (attachUnits && target.value.trim().length > 0 ? " " + currentUnits : "");

                            if (globalEditControls[globalControl.id] != undefined && parseInt(globalEditControls[globalControl.id]) < globalControlsOrder.length - 1) {

                                var nextId = globalControlsOrder[parseInt(globalEditControls[globalControl.id]) + 1]

                                if (typeof(__$(nextId)) != "undefined") {

                                    // __$(nextId).click();

                                    if (__$("target")) {

                                        document.body.removeChild(__$("target"));

                                    }

                                    setTimeout(function () {
                                        captureFreetext(__$(nextId));
                                    }, 25);

                                    return;

                                } else {

                                    if (__$("target")) {

                                        document.body.removeChild(__$("target"));

                                    }

                                }

                            } else {

                                if (__$("target")) {

                                    document.body.removeChild(__$("target"));

                                }

                            }

                            return;

                        } else {

                            if (target.value.trim() == "?" || target.value.trim() == "Unknown") {

                                target.value = (currentCaseUpper ? label.trim().toLowerCase() : label.trim());

                            } else {

                                if (overwriteNumber) {

                                    target.value = (currentCaseUpper ? label.trim().toLowerCase() : label.trim());

                                    overwriteNumber = false;

                                    if (target.value.trim().length > 0) {

                                        if (__$("CAP") && !currentCaseUpper) {

                                            __$("CAP").click();

                                        }

                                    }

                                } else {

                                    target.value += (currentCaseUpper ? label.trim().toLowerCase() : label.trim());

                                    if (target.value.trim().length > 0) {

                                        if (__$("CAP") && !currentCaseUpper) {

                                            __$("CAP").click();

                                        }

                                    }

                                }

                            }

                        }

                        if (!disabled['.']) {
                            __$('.').setAttribute('class', 'button_blue');
                        }

                    }, false);

                }


                if (String(keys[i][j]).trim() == "Unknown") {

                    button.style.fontSize = "14px";
                    cell.style.marginTop = "-10px";

                }

            }
        }

    }
}

function confirmAction(msg, action) {

    if (typeof(Android) != "undefined") {

        Android.confirmAction(msg, action);

    } else {

        if (confirm(msg)) {

            eval(action);

        }

    }

}

function showMsg(msg) {

    if (typeof(Android) != "undefined") {

        Android.showMsg(msg);

    } else {

        alert(msg);

    }

}

function captureFreetext(targetControl, addUnits, numeric, password) {

    if (addUnits == undefined) {

        addUnits = false;

    }

    attachUnits = addUnits;

    globalControl = targetControl;

    currentUnits = globalControl.getAttribute("units");

    if (currentUnits == null) {

        currentUnits = "";

    }

    var myString = (attachUnits ? targetControl.value.trim().replace(currentUnits, "").trim() : targetControl.value.trim());

    var divTarget = document.createElement("div");
    divTarget.id = "target";
    divTarget.style.position = "absolute";
    divTarget.style.left = "0px";
    divTarget.style.top = "0px";
    divTarget.style.height = "100%";
    divTarget.style.width = "100%";
    divTarget.style.backgroundColor = "rgba(0,0,0,0.8)";
    divTarget.style.padding = "10px";

    document.body.appendChild(divTarget);

    FastClick.attach(__$("target"));

    __$("target").onclick = function () {

        if (__$("target")) {

            if (__$("textArea")) {

                globalControl.value = __$("textArea").value.trim() + (attachUnits && __$("textArea").value.trim().length > 0 ? " " + currentUnits : "");

            }

            document.body.removeChild(__$("target"));

        }

    }

    var table = document.createElement("table");
    table.id = "myTable";
    table.style.margin = "auto";

    divTarget.appendChild(table);

    var tbody = document.createElement("tbody");

    table.appendChild(tbody);

    var tr1 = document.createElement("tr");

    tbody.appendChild(tr1);

    var tr2 = document.createElement("tr");

    tbody.appendChild(tr2);

    var td1 = document.createElement("td");

    tr1.appendChild(td1);

    var td2 = document.createElement("td");

    tr2.appendChild(td2);

    var inDiv = document.createElement("div");
    inDiv.style.height = "150px";
    inDiv.style.width = "100%";

    td1.appendChild(inDiv);

    var keysDiv = document.createElement("div");
    keysDiv.id = "keysDiv";
    keysDiv.style.width = "100%";

    td2.appendChild(keysDiv);

    var textArea = document.createElement("textarea");
    textArea.id = "textArea";
    textArea.style.width = "95%";
    textArea.style.height = "80%";
    textArea.style.padding = "10px";
    textArea.style.fontSize = "24px";

    textArea.style.setProperty("-webkit-user-select", "none");

    textArea.style.setProperty("-moz-user-select", "none");

    textArea.value = myString;

    if (targetControl.type == "password") {

        textArea.style.setProperty("-webkit-text-security", "circle");

    }

    textArea.onkeydown = function (e) {

        if (typeof(Android) == "undefined" && e.keyCode == 13) {

            if (__$(navKey)) {

                __$(navKey).click();

            }

        }

    }

    inDiv.appendChild(textArea);

    if (typeof(password) == "undefined") {

        password = false;

    }

    showKeyboard(textArea, "keysDiv", undefined, numeric, password);

    // showKeyboard(textArea, "keysDiv", undefined, numeric);

    textArea.focus();

}

function showMsgForAction(doc, title) {

    showShield(true);

    if (!__$("shield")) {

        showShield(true);

    }

    var popup = document.createElement("div");
    popup.id = "popup";
    popup.style.position = "absolute";
    popup.style.minHeight = "200px";
    popup.style.backgroundColor = "#fff";
    popup.style.zIndex = 120;
    popup.style.border = "2px outset #eee";
    popup.style.borderRadius = "8px";

    document.body.appendChild(popup);

    var table = document.createElement("table");
    table.width = "100%";
    table.style.fontSize = "24px";

    popup.appendChild(table);

    var tbody = document.createElement("tbody");

    table.appendChild(tbody);

    var tr1 = document.createElement("tr");

    tbody.appendChild(tr1);

    var th = document.createElement("th");
    th.innerHTML = (title == undefined ? "Info" : title);
    th.style.backgroundColor = "#345d8c";
    th.style.color = "#fff";
    th.style.borderTopLeftRadius = "8px";
    th.style.borderTopRightRadius = "8px";
    th.style.border = "2px outset #23538a";
    th.colSpan = "2";
    th.style.padding = "5px";

    tr1.appendChild(th);

    var tr2 = document.createElement("tr");

    tbody.appendChild(tr2);

    var td1_1 = document.createElement("td");
    td1_1.colSpan = "2";
    td1_1.style.padding = "5px";
    td1_1.style.paddingTop = "15px";
    td1_1.style.paddingBottom = "15px";
    td1_1.align = "center";
    td1_1.style.lineHeight = "120%";
    td1_1.style.fontSize = "20px";

    tr2.appendChild(td1_1);

    td1_1.innerHTML = doc;

    var tr3 = document.createElement("tr");

    tbody.appendChild(tr3);

    var td2_2 = document.createElement("td");
    td2_2.align = "center";
    td2_2.style.padding = "10px";
    td2_2.setAttribute("colspan", 2);

    tr3.appendChild(td2_2);

    var btnYes = document.createElement("button");
    btnYes.className = "button_blue";
    btnYes.innerHTML = "OK";
    btnYes.style.width = "120px";
    btnYes.style.cursor = "pointer";
    btnYes.style.fontSize = "24px";
    btnYes.style.minHeight = "60px";

    td2_2.appendChild(btnYes);

    btnYes.onmousedown = function () {

        if (__$("popup")) {

            document.body.removeChild(__$("popup"));

        }

        if (__$("shield")) {

            document.body.removeChild(__$("shield"));

        }

    }

    if (__$("popup")) {

        var c = checkCtrl(__$("popup"));

        __$("popup").style.top = ((window.innerHeight / 2) - (c[1] / 2)) + "px";

        __$("popup").style.left = ((window.innerWidth / 2) - (c[0] / 2)) + "px";

    }

}

function formatTimestamp(timestamp){

    var time = timestamp.match(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/);

    if(time != null){

        var months = ["Jan","Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

        var month = months[eval(time[2]) - 1];

        var date = eval(time[3]);

        var result = date + "/" + month + "/" + time[1] + " " + time[4] + ":" + time[5] + ":" + time[6];

        return result;

    } else {

        return timestamp;

    }

}

setTimeout(function () {
    init()
}, 500);

// $(document).ready(function(){ init() })
