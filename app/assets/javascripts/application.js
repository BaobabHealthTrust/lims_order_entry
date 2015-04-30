// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function displayTestState(accession_number, state, code, name, national_id,patient_name, element)
{
    var msg = ""

    if (state.trim().toLocaleLowerCase() == 'ordered')
    {
        confirmAction("Test for " + name +" was ordered but specimen hasn't been drawn. See patient details?", "window.location='/patient/"+national_id +"'")
    }
    else if (state.trim().toLocaleLowerCase() == 'drawn')
    {
        showMsg("Specimen for " + name +" test was drawn but has not arrived at the lab.")
    }
    else if (state.trim().toLocaleLowerCase() == 'sample rejected')
    {
        confirmAction("Sample for " + name +" test was rejected. Do you want to re-order the test?","window.location='/patient/"+national_id +"'");
        printResult(accession_number, state,'Seen', code, name,national_id,patient_name,[])
        removeRow(element)
    }
    else if (state.trim().toLocaleLowerCase() == 'test rejected')
    {
        confirmAction(name+" test could not be run on available specimen. Do you want to re-order the test?", "window.location='/patient/"+national_id +"'");
        printResult(accession_number, state,'Seen', code, name,national_id,patient_name, [])
        removeRow(element)
    }
    else if (state.trim().toLocaleLowerCase() == 'result rejected')
    {
        confirmAction("Results for "+name+" were inconclusive. Do you want to re-order the test?", "window.location='/patient/"+national_id +"'");
        printResult(accession_number, state,'Seen', code, name,national_id,patient_name, [])
        removeRow(element)
    }

}

function printResult(accession_number, currentState, newState, code, name,national_id,patient_name,results)
{

    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    var url = "/update_state/" + accession_number + "?state="+newState+"&test_code=" + code + "&test_name=" + name;

    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function () {

        if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
            httpRequest.status == 304)) {

            var datetime = (new Date()).getDate() + "/" + months[(new Date()).getMonth()] + "/" + (new Date()).getFullYear() +
                " " + (new Date()).getHours() + ":" + (new Date()).getMinutes();

            var currentTests = "";

            if (newState.trim().toLocaleLowerCase() == "reviewed" || currentState.trim().toLocaleLowerCase() == "verified" || currentState.trim().toLocaleLowerCase() == "tested") {

                var tests = results[0]["orders"][accession_number]["results"];

                var keys = Object.keys(tests);

                for (var i = 0; i < keys.length; i++) {

                    var test = tests[keys[i]]["test_name"];

                    var result = tests[keys[i]]["result"];

                    if (result.trim().length == 0) {
                        continue;
                    }

                    var datetime = tests[keys[i]]["result_date_time"];

                    var yr = datetime.substr(0, 4);

                    var month = months[parseInt(datetime.substr(4, 2)) - 1];

                    var date = parseInt(datetime.substr(6, 2));

                    var hr = datetime.substr(8, 2);

                    var min = datetime.substr(10, 2);

                    var dateFormatted = date + "/" + month + "/" + yr + " " + hr + ":" + min;

                    currentTests += dateFormatted + "|" + test + "|" + result + ";"

                }
                printBarcodeMain(datetime, currentTests, accession_number, undefined, "reviewed", national_id,patient_name);
            }


        }

    };
    try {
        httpRequest.open('GET', url, true);
        httpRequest.send(null);
    } catch (e) {
    }

}

function printBarcodeMain(messageDatetime, testsTBD, accessionNumber, ward, state, national_id, patient_name) {

    if (ward == undefined) {

        ward = "";

    }

    if (state == undefined) {

        state = "";

    }

    var npid = national_id;
    var full_name = patient_name;

    if (state == "reviewed") {

        if (typeof(Android) != "undefined") {

            // public void printResultBarcode(String testsTBD, String identifier, String name)
            Android.printResultBarcode(testsTBD, npid, full_name);

        } else {

            alert(testsTBD);

        }

    } else {
        // printBarcode(String name, String npid, String datetime, String ward, String test, String barcode)
        if (typeof(Android) != "undefined") {

            Android.printBarcode(full_name, npid, messageDatetime, ward, testsTBD, accessionNumber);

        } else {

            alert("Accession Number: " + accessionNumber + "; testsTBD: " + testsTBD);

        }
    }

    window.location = window.location.href;

}

function updateState(state)
{

}