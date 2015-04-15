

function __$(id) {
    return document.getElementById(id);
}

function showShield(clickCloses) {

    if (clickCloses == undefined) {

        clickCloses = false;

    }

    if (__$("shield")) {

        document.body.removeChild(__$("shield"));

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
            /*
             new FastButton(shield, function () {

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

             });
             */

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

        if (currentKeysNumeric) {

            keys = [
                [1, 2, 3, ':'],
                [4, 5, 6, '/'],
                [7, 8, 9, '.'],
                ['&larr;', 0, '', 'abc', "OK"]
            ];

        } else {

            if (currentKeysQWERTY) {

                keys = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                    ['', "Z", "X", "C", "V", "B", "N", "M", '', "CAP"],
                    ['', '&nbsp;', '&larr;', ":", ".", "/", "num", "abc", "OK"]
                ];

            } else {

                keys = [
                    ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
                    ["J", "K", "L", "M", "N", "O", "P", "Q", "R"],
                    ["S", "T", "U", "V", "W", "X", "Y", "Z", "CAP"],
                    ['', '&nbsp;', '&larr;', ":", ".", "/", "num", "qwe", "OK"]
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

            for (var j = 0; j < keys[i].length; j++) {
                var cell = document.createElement('div');
                cell.style.display = 'table-cell';

                row.appendChild(cell);

                if (String(keys[i][j]).trim().length == 0) {
                    cell.innerHTML = "&nbsp;";

                    continue;
                }

                var button = document.createElement('button');
                button.setAttribute('class', (disabled[keys[i][j]] ? 'button_gray' : 'button_blue'));
                button.style.width = '45px';
                button.style.height = '60px';
                button.style.minWidth = '40px';
                button.style.minHeight = '40px';
                button.style.margin = '2px';
                button.style.fontSize = "24px";
                button.setAttribute("parent", container.id);

                cell.appendChild(button);

                if (keys[i][j] != "num" && keys[i][j] != "qwe" && keys[i][j] != "abc") {

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

                } else if (keys[i][j] == "OK" || keys[i][j] == "num" || keys[i][j] == "qwe" || keys[i][j] == "abc" || keys[i][j] == "cap" || keys[i][j] == "CAP") {

                    button.style.fontSize = "14px";
                    button.style.padding = "0px";
                    // button.style.marginTop = "-10px";

                }

                if (letters[keys[i][j]]) {

                    button.innerHTML = (String(keys[i][j]).trim().toLowerCase() == "cap" ? (!currentCaseUpper ? String(keys[i][j]).toLowerCase() : String(keys[i][j]).toUpperCase()) : (!currentCaseUpper ? String(keys[i][j]).toUpperCase() : String(keys[i][j]).toLowerCase()));

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

                        if (this.innerHTML.trim().charCodeAt(0) == 8592) {
                            if (target) {
                                target.value = target.value.trim().substring(0, (target.value.trim().length - 1));
                            }

                        } else if (this.innerHTML.trim() == 'num') {

                            currentKeysNumeric = true;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == 'abc') {

                            currentKeysQWERTY = false;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == 'qwe') {

                            currentKeysQWERTY = true;

                            currentKeysNumeric = false;

                            showKeyboard(__$(target.id), this.getAttribute("parent"), disabled, currentKeysNumeric, currentCaseUpper);

                        } else if (this.innerHTML.trim() == '?') {

                            target.value = "?";

                        } else if (this.innerHTML.trim().toLowerCase() == 'cap') {
                            currentCaseUpper = !currentCaseUpper;

                            var keys = Object.keys(letters);

                            if (!currentCaseUpper) {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toUpperCase();
                                    }
                                }

                                this.innerHTML = "cap";

                            } else {

                                for (var l = 0; l < keys.length - 1; l++) {
                                    if (__$(keys[l])) {
                                        __$(keys[l]).innerHTML = keys[l].toLowerCase();
                                    }
                                }

                                this.innerHTML = "CAP";

                            }

                        } else if (this.innerHTML.trim() == '&nbsp;') {

                            target.value += " ";

                        } else if (this.innerHTML.trim() == 'OK') {

                            globalControl.value = target.value.trim() + (attachUnits && target.value.trim().length > 0 ? " " + currentUnits : "");

                            captureFreetext(target);

                            return;

                        } else {

                            if (target.value.trim() == "?" || target.value.trim() == "Unknown") {

                                target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                            } else {

                                if (overwriteNumber) {

                                    target.value = (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

                                    overwriteNumber = false;

                                    if (target.value.trim().length > 0) {

                                        if (__$("CAP") && !currentCaseUpper) {

                                            __$("CAP").click();

                                        }

                                    }

                                } else {

                                    target.value += (currentCaseUpper ? this.innerHTML.trim().toLowerCase() : this.innerHTML.trim());

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

var attachUnits = false;

var currentUnits = "";

function captureFreetext(targetControl, addUnits, numeric, password) {

    if (__$("target")) {

        document.body.removeChild(__$("target"));

    } else {

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

                if (__$("OK")) {

                    __$("OK").click();

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

}
