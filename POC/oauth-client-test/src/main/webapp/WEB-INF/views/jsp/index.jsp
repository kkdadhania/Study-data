<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="req" value="${pageContext.request}" />
<c:set var="url">${req.requestURL}</c:set>
<c:set var="uri" value="${req.requestURI}" />

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Configure Oauth2</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

        <script>
            var ACCESS_TOKEN_URL;
            var formData;
            $(function () {
                $("#getToken").on("click", function () {
                    $("#OauthRefreshToken").hide();
                    $("#OauthResource").hide();
                    //get all parameters from form
                    formData = objectifyForm($("#outh2form").serializeArray());
                    //read access token URL parameters
                    var trList = $("#accessTokenParameters").children("div").children(".table").children("tbody").children("tr");
                    formData.accessTokenURLParameters = getData(trList);
                    trList = $("#accessTokenHeader").children("div").children(".table").children("tbody").children("tr");
                    formData.accessTokenURLHeaders = getData(trList);
                    trList = $("#authParameters").children("div").children(".table").children("tbody").children("tr");
                    formData.authURLParameters = getData(trList);
                    var REDIRECT = $("#callbackURL").val();
                    formData.callbackURL = REDIRECT;
                    console.log(formData);

                    if (formData.grantType === "authorization_code") {
                        ACCESS_TOKEN_URL = formData.accessTokenURL;
                        var _url = formData.authURL + "?response_type=code" +
                                "&client_id=" + formData.clientId +
                                "&redirect_uri=" + encodeURIComponent(REDIRECT);
                        if (formData.scope !== "") {
                            _url += "&scope=" + encodeURIComponent(formData.scope);
                        }
                        if (formData.authURLParameters !== null) {
                            $.each(formData.authURLParameters, function (index, item) {
                                _url += "&" + item.name + "=" + item.value;
                            });
                        }

                        //+
//                            "&connection = wordpress"+
//                            "&access_type = myblog.wordpress.com"+
//                            "&state = OPAQUE_VALUE"
                        console.log(_url);
                        var win = window.open(_url, "windowname1", 'width=800, height=600');
                        var pollTimer = window.setInterval(function () {
                            try {
                                if (win == null || win == undefined || win.document == null || win.document == undefined || win.document.URL == null || win.document.URL == undefined) {
                                    window.clearInterval(pollTimer);
                                }
                                console.log(win.document.URL);
                                if (win.document.URL.startsWith(REDIRECT)) {
                                    window.clearInterval(pollTimer);
                                    var url = win.document.URL;
                                    var code = gup(url, 'code');
                                    win.close();
                                    validateToken(code);
                                }
                            } catch (e) {
                                console.error(e);
                            }
                        }, 100);
                    } else {
                        validateToken("nocode");
                    }

                    return false;
                });

                //add extra param logic 
                $(".add").on("click", function () {
                    var me = $(this);
                    var parentDiv = me.closest("div");
                    var name = parentDiv.children(".name").children("input").val();
                    var value = parentDiv.children(".value").children("input").val();
                    var tr = '<tr>' +
                            '<td class="name" colspan=3>' + name + '</td>' +
                            '<td class="value" colspan=3>' + value + '</td>' +
                            '<td class="deleteMe" colspan=1>delete</td>' +
                            '</tr>';

                    parentDiv.next().children('.table').children("tbody").append(tr);
                    parentDiv.children(".name").children("input").val("");
                    parentDiv.children(".value").children("input").val("");
                });

                $("body").on("click", ".deleteMe", function () {
                    var me = $(this);
                    me.closest("tr").remove();
                });

                $("#refreshRequired").on("click", function () {
                    if (this.checked) {
                        //Do stuff
                        $("#oauth2Refreshdiv").show();
                    } else {
                        $("#oauth2Refreshdiv").hide();
                    }
                });

                $("#getData").on("click", function () {
                    $(".apiResponse").text("");
                    var formData = objectifyForm($("#oauth2ResourceForm").serializeArray());
                    //read access token URL parameters
                    var trList = $("#parameters").children("div").children(".table").children("tbody").children("tr");
                    formData.parameters = getData(trList);
                    var trList = $("#headers").children("div").children(".table").children("tbody").children("tr");
                    formData.headers = getData(trList);
                    formData.accessToken = $("#accessTokenResult").text();
                    formData.tokenType = $("#tokenTypeResult").text();
                    $.ajax({
                        url: "resource",
                        type: "POST",
                        contentType: 'application/json',
                        processData: false,
                        data: JSON.stringify(formData),
                        success: function (responseText) {
                            console.log("responseText");
                            console.log(responseText);
                            $(".apiResponse").text(responseText.response);
                        },
                        error: function (xhr, status, error) {
                            console.log(status, error);
                            alert("error");
                        }

                    });
                    return false;
                });

                $("#updateToken").on("click", function () {
                     $(".apiRefresh").text("");
                    var formData = objectifyForm($("#oauth2RefreshForm").serializeArray());
                    formData.accessToken = $("#accessTokenResult").text();
                    formData.tokenType = $("#tokenTypeResult").text();
                    formData.expiry = $("#expiryResult").text();
                    formData.refreshToken = $("#refreshTokenResult").text();
                    formData.clientId = $("#clientId").val();
                    formData.clientSecret = $("#clientSecret").val();

                    var trList = $("#accessTokenParameters").children("div").children(".table").children("tbody").children("tr");
                    formData.accessTokenURLParameters = getData(trList);
                    trList = $("#accessTokenHeader").children("div").children(".table").children("tbody").children("tr");
                    formData.accessTokenURLHeaders = getData(trList)

                    $.ajax({
                        url: "refresh",
                        type: "POST",
                        contentType: 'application/json',
                        processData: false,
                        data: JSON.stringify(formData),
                        success: function (responseText) {
                            console.log("responseText");
                            console.log(responseText);
                            $(".apiRefresh").text(responseText.response);
                            if (responseText.code == "100") {
                                var rspJson = JSON.parse(responseText.response);
                                if (rspJson.access_token) {
                                    $("#accessTokenResult").text(rspJson.access_token);
                                }
                                if (rspJson.expires_in) {
                                    $("#expiryResult").text(rspJson.expires_in);
                                }
                                if (rspJson.token_type) {
                                    $("#tokenTypeResult").text(rspJson.token_type);
                                }
                                if (rspJson.refresh_token) {
                                    $("#refreshTokenResult").text(rspJson.refresh_token);
                                }
                            }
                        },
                        error: function (xhr, status, error) {
                            console.log(status, error);
                            alert("error");
                        }

                    });
                    return false;
                });
            });


            function gup(url, name) {
                name = name.replace(/[\[\]]/g, "\\$&");
                var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                        results = regex.exec(url);
                if (!results)
                    return null;
                if (!results[2])
                    return '';
                return results[2];
            }

            function validateToken(code) {
                console.log(code);

//                var _url = ACCESS_TOKEN_URL + "?code=" + code +
//                        "&client_id=" + formData.clientId +
//                        "&client_secret=" + formData.clientSecret;
//                console.log(_url);
                formData.code = code;
                $.ajax({
                    url: "access_token",
                    type: "POST",
                    contentType: 'application/json',
                    processData: false,
                    data: JSON.stringify(formData),
                    success: function (responseText) {
                        console.log("responseText");
                        console.log(responseText);
                        if (responseText.code == "100") {
                            $("#accessTokenResult").text("");
                            $("#expiryResult").text("");
                            $("#refreshTokenResult").text("");
                            $("#tokenTypeResult").text("");
                            var apiResponse = responseText.response;
                            $("#apiResponse").text(apiResponse);
                            var apiResponseType = responseText.responseType;
                            if (apiResponseType.startsWith("application/json")) {
                                var rspJson = JSON.parse(apiResponse);
                                $("#accessTokenResult").text(rspJson.access_token);
                                $("#expiryResult").text(rspJson.expires_in);
                                $("#refreshTokenResult").text(rspJson.refresh_token);
                                $("#tokenTypeResult").text(rspJson.token_type);
                                $("#OauthRefreshToken").show();
                                $("#OauthResource").show();
                            } else {
                                alert("response format is not yet supported " + apiResponseType);
                            }

                        } else {
                            var apiResponse = responseText.response;
                            $("#apiResponse").text(apiResponse);
                            alert("unable to get access token");
                        }

                    },
                    error: function (xhr, status, error) {
                        console.log(status, error);

                        alert("unable to get access token");
                    }

                });

            }

            function objectifyForm(formArray) {//serialize data function

                var formObj = {};
                for (var i = 0; i < formArray.length; i++) {
                    formObj[formArray[i]['name']] = formArray[i]['value'];
                }
                return formObj;
            }
            function getData(trList) {
                var params = [];
                $.each(trList, function (index, item) {
                    console.log(item, index);
                    var thisItem = $(item);
                    var name = thisItem.children(".name").text();
                    var value = thisItem.children(".value").text();

                    params.push({
                        name: name,
                        value: value
                    });
                });
                return params;
            }
        </script>
    </head>
    <body>
        <div class="container">

            <h2>Configure Oauth2</h2>
            <div>
                <form action="" id="outh2form">
                    <div class="form-group">
                        <label for="callBackURL" >Call Back URL:</label>
                        <input type="text" class="form-control" id="callbackURL" disabled value="${fn:substring(url, 0, fn:length(url) - fn:length(uri))}${req.contextPath}/callback" name="callBackURL">
                    </div>
                    <div class="form-group">
                        <label for="authURL" >Auth URL:</label>
                        <input type="text" class="form-control" id="authURL" placeholder="Enter Auth URL" name="authURL">
                    </div>
                    <div class="form-group">
                        <label for="accessTokenURL" >Acess Token URL:</label>
                        <input type="text" class="form-control" id="accessTokenURL" placeholder="Enter Access Token URL" name="accessTokenURL">
                    </div>
                    <div class="form-group">
                        <label for="clientId" >Client Id:</label>
                        <input type="text" class="form-control" id="clientId" placeholder="Enter Client Id" name="clientId">
                    </div>
                    <div class="form-group">
                        <label for="clientSecret" >Client Secret:</label>
                        <input type="text" class="form-control" id="clientSecret" placeholder="Enter Client Secret" name="clientSecret">
                    </div>
                    <div class="form-group">
                        <label for="scope" >Scope:</label>
                        <input type="text" class="form-control" id="scope" placeholder="Enter Scope" name="scope">
                    </div>
                    <div id="authParameters">
                        <h3>Auth URL Parameters:</h3>
                        <div class="form-inline">
                            <div class="form-group name">
                                <label for="name" >Name:</label>
                                <input type="text" class="form-control" id="name"  name="name">
                            </div>
                            <div class="form-group value">
                                <label for="value" >Value:</label>
                                <input type="text" class="form-control" id="value" name="value">
                            </div>
                            <input type="button" class="add" value="Add" id="submit" />
                        </div>
                        <div id='table'>
                            <table class='table table-hover'>
                                <thead>
                                    <tr id="title">
                                        <th colspan=3>Name</th><th colspan=3>Value</th><th colspan="1">Action</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="accessTokenMethod" >Access Token URL Method:</label>
                        <select class="form-control" id="accessTokenMethod" name="accessTokenMethod">
                            <option selected value="POST">POST</option>
                            <option value="GET">GET</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="accessTokenParameterType" >Access Token URL Parameter Type:</label>
                        <select class="form-control" id="accessTokenParameterType" name="accessTokenParameterType">
                            <option selected value="BODY">Body</option>
                            <option value="URL">URL</option>
                        </select>
                    </div>
                    <div id="accessTokenParameters">
                        <h3><span>Access Token URL Parameters:</h3>
                        <div class="form-inline">
                            <div class="form-group name">
                                <label for="name" >Name:</label>
                                <input type="text" class="form-control" id="name"  name="name">
                            </div>
                            <div class="form-group value">
                                <label for="value" >Value:</label>
                                <input type="text" class="form-control" id="value" name="value">
                            </div>
                            <input type="button" class="add" value="Add" id="submit" />
                        </div>
                        <div id='table'>
                            <table class='table table-hover'>
                                <thead>
                                    <tr id="title">
                                        <th colspan=3>Name</th><th colspan=3>Value</th><th colspan="1">Action</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div id="accessTokenHeader">
                        <h3><span>Access Token URL Headers</h3>
                        <div class="form-inline">
                            <div class="form-group name">
                                <label for="name" >Name:</label>
                                <input type="text" class="form-control" id="name"  name="name">
                            </div>
                            <div class="form-group value">
                                <label for="value" >Value:</label>
                                <input type="text" class="form-control" id="value" name="value">
                            </div>
                            <input type="button" class="add" value="Add" id="submit" />
                        </div>
                        <div id='table'>
                            <table class='table table-hover'>
                                <thead>
                                    <tr id="title">
                                        <th colspan=3>Name</th><th colspan=3>Value</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="grantType" >Grant Type:</label>
                        <select class="form-control" id="grantType" name="grantType">
                            <option selected value="authorization_code">Authorization Code</option>
                            <option value="client_credentials">Client Credentials</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-default" id="getToken">Get Tokens</button>
                </form>

            </div>
            <br/>
            <div id="errorBlockId" style="display: none">
                <div class="alert alert-success" role="alert">
                    <span class="sr-only">Success:</span>
                    Enter a valid email address
                </div>
                <div class="alert alert-danger" role="alert">
                    <span class="sr-only">Error:</span>
                    Enter a valid email address
                </div>
            </div>
            <div id="resultId">
                <figure  class="highlight">
                    <pre>
                        <code id="apiResponse" class="language-html" data-lang="json"></code>
                    </pre>
                </figure>
                <span>Access Token:</span>
                <figure class="highlight"><pre>
                    <code id="accessTokenResult" class="language-bash" data-lang="bash"></code>
                    </pre>
                </figure>
                <span>Refresh Token:</span>
                <figure class="highlight"><pre>
                    <code id="refreshTokenResult" class="language-bash" data-lang="bash"></code>
                    </pre>
                </figure>
                <span>Expiry:</span>
                <figure class="highlight"><pre>
                    <code id="refreshTokenResult" class="language-bash" data-lang="bash"></code>
                    </pre>
                </figure>
                <span>Token Type:</span>
                <figure class="highlight"><pre>
                    <code id="tokenTypeResult" class="language-bash" data-lang="bash"></code>
                    </pre>
                </figure>

            </div>
            <div class="container" id="OauthRefreshToken" style="display: none">
                <!--<div class="container" id="OauthRefreshToken">-->
                <label class="checkbox-inline"><input type="checkbox" id="refreshRequired">Refresh Required</label>
                <div id="oauth2Refreshdiv" style="display: none">
                    <h2>Configure Refresh Oauth2</h2>
                    <form action="" id="oauth2RefreshForm" >
                        <div class="form-group">
                            <label for="accessTokenURL" >Access URL:</label>
                            <input type="text" class="form-control" id="accessTokenURL" placeholder="Enter Refresh Auth URL" name="accessTokenURL">
                        </div>
                        <div class="form-group">
                            <label for="accessTokenMethod" >Access Token URL Method:</label>
                            <select class="form-control" id="accessTokenMethod" name="accessTokenMethod">
                                <option selected value="POST">POST</option>
                                <option value="GET">GET</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="accessTokenParameterType" >Access Token URL Parameter Type:</label>
                            <select class="form-control" id="accessTokenParameterType" name="accessTokenParameterType">
                                <option selected value="BODY">Body</option>
                                <option value="URL">URL</option>
                            </select>
                        </div>
                        <div id="accessTokenParameters">
                            <h3><span>Access Token URL Parameters:</h3>
                            <div class="form-inline">
                                <div class="form-group name">
                                    <label for="name" >Name:</label>
                                    <input type="text" class="form-control" id="name"  name="name">
                                </div>
                                <div class="form-group value">
                                    <label for="value" >Value:</label>
                                    <input type="text" class="form-control" id="value" name="value">
                                </div>
                                <input type="button" class="add" value="Add" id="submit" />
                            </div>
                            <div id='table'>
                                <table class='table table-hover'>
                                    <thead>
                                        <tr id="title">
                                            <th colspan=3>Name</th><th colspan=3>Value</th><th colspan="1">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div id="accessTokenHeader">
                            <h3><span>Access Token URL Headers</h3>
                            <div class="form-inline">
                                <div class="form-group name">
                                    <label for="name" >Name:</label>
                                    <input type="text" class="form-control" id="name"  name="name">
                                </div>
                                <div class="form-group value">
                                    <label for="value" >Value:</label>
                                    <input type="text" class="form-control" id="value" name="value">
                                </div>
                                <input type="button" class="add" value="Add" id="submit" />
                            </div>
                            <div id='table'>
                                <table class='table table-hover'>
                                    <thead>
                                        <tr id="title">
                                            <th colspan=3>Name</th><th colspan=3>Value</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-default" id="updateToken">Update Token</button>
                    </form>
                </div>
                <div id="resouresResult">
                    <figure  class="highlight">
                        <pre>
                        <code class="language-html apiRefresh" data-lang="json">                            
                        </code>
                        </pre>
                    </figure>
                </div>
            </div>
            <div class="container" id="OauthResource" style="display: none">
                <h2>Resource Access Oauth2</h2>
                <div id="oauth2Resourcediv" >
                    <form action="" id="oauth2ResourceForm" >
                        <div class="form-group">
                            <label for="accessTokenType" >Access Token Send Type:</label>
                            <select class="form-control" id="accessTokenType" name="accessTokenType">
                                <option selected value="HEADER">HEADER</option>
                                <option  value="URL">URL</option>

                            </select>
                        </div>
                        <div class="form-group">
                            <label for="URL" >URL:</label>
                            <input type="text" class="form-control" id="URL" placeholder="Enter  URL" name="URL">
                        </div>

                        <div class="form-group">
                            <label for="method" >Method:</label>
                            <select class="form-control" id="method" name="method">
                                <option selected value="POST">POST</option>
                                <option value="GET">GET</option>
                            </select>
                        </div>
                        <!--                        <div class="form-group">
                                                    <label for="parameterType" >Parameter Type:</label>
                                                    <select class="form-control" id="parameterType" name="parameterType">
                                                        <option selected value="BODY">Body</option>
                                                        <option value="URL">URL</option>
                                                    </select>
                                                </div>-->
                        <div id="parameters">
                            <h3><span>Access Token URL Parameters:</h3>
                            <div class="form-inline">
                                <div class="form-group name">
                                    <label for="name" >Name:</label>
                                    <input type="text" class="form-control" id="name"  name="name">
                                </div>
                                <div class="form-group value">
                                    <label for="value" >Value:</label>
                                    <input type="text" class="form-control" id="value" name="value">
                                </div>
                                <input type="button" class="add" value="Add" id="submit" />
                            </div>
                            <div id='table'>
                                <table class='table table-hover'>
                                    <thead>
                                        <tr id="title">
                                            <th colspan=3>Name</th><th colspan=3>Value</th><th colspan="1">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div id="headers">
                            <h3><span>Access Token URL Headers</h3>
                            <div class="form-inline">
                                <div class="form-group name">
                                    <label for="name" >Name:</label>
                                    <input type="text" class="form-control" id="name"  name="name">
                                </div>
                                <div class="form-group value">
                                    <label for="value" >Value:</label>
                                    <input type="text" class="form-control" id="value" name="value">
                                </div>
                                <input type="button" class="add" value="Add" id="submit" />
                            </div>
                            <div id='table'>
                                <table class='table table-hover'>
                                    <thead>
                                        <tr id="title">
                                            <th colspan=3>Name</th><th colspan=3>Value</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="body" >Body:</label>
                            <input type="text" class="form-control" id="body" placeholder="Enter body" name="body">
                        </div>
                        <button type="submit" class="btn btn-default" id="getData">Get Data</button>
                    </form>
                </div>
                <div id="resouresResult">
                    <figure  class="highlight">
                        <pre>
                        <code class="language-html apiResponse" data-lang="json">                            
                        </code>
                        </pre>
                    </figure>
                </div>
            </div>
        </div>
    </body>
</html>
