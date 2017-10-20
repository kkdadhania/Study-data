/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.imimobile.oauth.client.test.service;

import com.imi.wf.beans.HttpClientRequest;
import com.imi.wf.common.HttpClientUtil;
import com.imi.wf.common.Utilities;
import com.imimobile.oauth.client.test.bean.ApiResonse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import org.springframework.stereotype.Service;

/**
 *
 * @author sadashiv.k
 */
@Service
public class OuthServiceImpl implements OuthService {

    private static Logger logger = Logger.getLogger(OuthServiceImpl.class);

    @Override
    public ApiResonse getAccessTokenByCode(String request) {
        ApiResonse apiResonse;
        try {
            JSONObject json = new JSONObject(request);
            HttpClientRequest clientRequest = new HttpClientRequest();
            HttpClientUtil.METHOD method = HttpClientUtil.METHOD.getMethod(json.optString("accessTokenMethod", "POST"));
            clientRequest.setMethod(method);
            clientRequest.setUrl(json.optString("accessTokenURL", ""));
            Map<String, String> parameters = new HashMap<>();
            JSONArray accessTokenURLParametes = json.getJSONArray("accessTokenURLParameters");
            if (accessTokenURLParametes != null) {
                for (int i = 0; i < accessTokenURLParametes.length(); i++) {
                    JSONObject item = accessTokenURLParametes.getJSONObject(i);
                    parameters.put(item.optString("name", ""), item.optString("value", ""));
                }
            }

            parameters.put("client_id", json.optString("clientId", ""));
            parameters.put("client_secret", json.optString("clientSecret", ""));
            String grantType = json.optString("grantType", "authorization_code");
            parameters.put("grant_type", grantType);
            if (grantType.equalsIgnoreCase("authorization_code")) {
                parameters.put("redirect_uri", json.optString("callbackURL", ""));
                parameters.put("code", json.optString("code", ""));
            }else{
                parameters.put("scope", json.optString("scope", ""));
            }
            
            if (json.optString("accessTokenParameterType", "URL").equalsIgnoreCase("BODY")) {
                List<NameValuePair> postParameters = new ArrayList<>();
                for (Map.Entry<String, String> entry : parameters.entrySet()) {//TODO -validation
                    postParameters.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
                }
                clientRequest.setRequestEntity(new UrlEncodedFormEntity(postParameters, "UTF-8"));
            } else {
                clientRequest.setUrlParameters(parameters);
            }

            Map<String, String> headers = new HashMap<>();
            JSONArray accessTokenHeaders = json.getJSONArray("accessTokenURLHeaders");
            if (accessTokenHeaders != null) {
                for (int i = 0; i < accessTokenHeaders.length(); i++) {
                    JSONObject item = accessTokenHeaders.getJSONObject(i);
                    headers.put(item.optString("name", ""), item.optString("value", ""));
                }
            }
            clientRequest.setHeaders(headers);

            HttpResponse execute = HttpClientUtil.execute(clientRequest);
            String resonse = EntityUtils.toString(execute.getEntity());
            logger.info(resonse);
            Header contentTypeHeader = execute.getFirstHeader("Content-Type");
            String responseType = "";
            if (contentTypeHeader != null) {
                responseType = contentTypeHeader.getValue();
            }
            if (execute.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                //success
                apiResonse = ApiResonse.generateStatus("100", "success", responseType, resonse);
            } else {
                apiResonse = ApiResonse.generateStatus("101", "error , status  :" + execute.getStatusLine().getStatusCode() + " ,  status text : " + execute.getStatusLine().getReasonPhrase(), responseType, resonse);
            }
        } catch (Exception ex) {
            logger.error(ex, ex);
            apiResonse = ApiResonse.generateError();
        }
        return apiResonse;
    }

    @Override
    public ApiResonse getRecourceData(String request) {
        ApiResonse apiResonse;
        try {
            JSONObject json = new JSONObject(request);
            HttpClientRequest clientRequest = new HttpClientRequest();
            HttpClientUtil.METHOD method = HttpClientUtil.METHOD.getMethod(json.optString("method", "GET"));
            clientRequest.setMethod(method);
            clientRequest.setUrl(json.optString("URL", ""));
            Map<String, String> parameters = new HashMap<>();
            JSONArray accessTokenURLParametes = json.getJSONArray("parameters");
            if (accessTokenURLParametes != null) {
                for (int i = 0; i < accessTokenURLParametes.length(); i++) {
                    JSONObject item = accessTokenURLParametes.getJSONObject(i);
                    parameters.put(item.optString("name", ""), item.optString("value", ""));
                }
            }
            clientRequest.setUrlParameters(parameters);
//            if (json.optString("parameterType", "URL").equalsIgnoreCase("BODY")) {
//                List<NameValuePair> postParameters = new ArrayList<>();
//                for (Map.Entry<String, String> entry : parameters.entrySet()) {//TODO -validation
//                    postParameters.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
//                }
//                clientRequest.setRequestEntity(new UrlEncodedFormEntity(postParameters, "UTF-8"));
//            } else {
//               
//            }
            String body = json.optString("body", "");
            if (Utilities.isNotBlank(body)) {
                clientRequest.setRequestEntity(new StringEntity(body));
            }

            Map<String, String> headers = new HashMap<>();
            JSONArray accessTokenHeaders = json.getJSONArray("headers");
            if (accessTokenHeaders != null) {
                for (int i = 0; i < accessTokenHeaders.length(); i++) {
                    JSONObject item = accessTokenHeaders.getJSONObject(i);
                    headers.put(item.optString("name", ""), item.optString("value", ""));
                }
            }
            clientRequest.setHeaders(headers);
            if (json.optString("accessTokenType", "HEADER").equalsIgnoreCase("URL")) {
                Map<String, String> configureURLParameters = clientRequest.getUrlParameters();
                if (configureURLParameters == null) {
                    configureURLParameters = new HashMap<>();
                }
                configureURLParameters.put("access_token", json.optString("accessToken", ""));
                clientRequest.setUrlParameters(configureURLParameters);
            } else {
                Map<String, String> configureResources = clientRequest.getHeaders();
                if (configureResources == null) {
                    configureResources = new HashMap<>();
                }
//                configureResources.put("Authorization", json.optString("tokenType", "Bearer") + " " + json.optString("accessToken", ""));
                configureResources.put("Authorization", "Bearer " + json.optString("accessToken", ""));
                clientRequest.setHeaders(configureResources);
            }

            HttpResponse execute = HttpClientUtil.execute(clientRequest);
            String resonse = EntityUtils.toString(execute.getEntity());
            logger.info(resonse);
            Header contentTypeHeader = execute.getFirstHeader("Content-Type");
            String responseType = "";
            if (contentTypeHeader != null) {
                responseType = contentTypeHeader.getValue();
            }
            if (execute.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                //success
                apiResonse = ApiResonse.generateStatus("100", "success", responseType, resonse);
            } else {
                apiResonse = ApiResonse.generateStatus("101", "error , status  :" + execute.getStatusLine().getStatusCode() + " ,  status text : " + execute.getStatusLine().getReasonPhrase(), responseType, resonse);
            }
        } catch (Exception ex) {
            logger.error(ex, ex);
            apiResonse = ApiResonse.generateError();
        }
        return apiResonse;
    }

    @Override
    public ApiResonse refreshToken(String request) {
        ApiResonse apiResonse;
        try {
            JSONObject json = new JSONObject(request);
            HttpClientRequest clientRequest = new HttpClientRequest();
            HttpClientUtil.METHOD method = HttpClientUtil.METHOD.getMethod(json.optString("accessTokenMethod", "POST"));
            clientRequest.setMethod(method);
            clientRequest.setUrl(json.optString("accessTokenURL", ""));
             Map<String, String> parameters = new HashMap<>();
            parameters.put("client_id", json.optString("clientId", ""));
            parameters.put("client_secret", json.optString("clientSecret", ""));
            parameters.put("grant_type", "refresh_token");
            parameters.put("refresh_token", json.optString("refreshToken", ""));

            
            JSONArray accessTokenURLParametes = json.getJSONArray("accessTokenURLParameters");
            if (accessTokenURLParametes != null) {
                for (int i = 0; i < accessTokenURLParametes.length(); i++) {
                    JSONObject item = accessTokenURLParametes.getJSONObject(i);
                    parameters.put(item.optString("name", ""), item.optString("value", ""));
                }
            }
            if (json.optString("accessTokenParameterType", "URL").equalsIgnoreCase("BODY")) {
                List<NameValuePair> postParameters = new ArrayList<>();
                for (Map.Entry<String, String> entry : parameters.entrySet()) {//TODO -validation
                    postParameters.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
                }
                clientRequest.setRequestEntity(new UrlEncodedFormEntity(postParameters, "UTF-8"));
            } else {
                clientRequest.setUrlParameters(parameters);
            }
            
            Map<String, String> headers = new HashMap<>();
            JSONArray accessTokenHeaders = json.getJSONArray("accessTokenURLHeaders");
            if (accessTokenHeaders != null) {
                for (int i = 0; i < accessTokenHeaders.length(); i++) {
                    JSONObject item = accessTokenHeaders.getJSONObject(i);
                    headers.put(item.optString("name", ""), item.optString("value", ""));
                }
            }
            clientRequest.setHeaders(headers);
            
            HttpResponse execute = HttpClientUtil.execute(clientRequest);
            String resonse = EntityUtils.toString(execute.getEntity());
            logger.info(resonse);
            Header contentTypeHeader = execute.getFirstHeader("Content-Type");
            String responseType = "";
            if (contentTypeHeader != null) {
                responseType = contentTypeHeader.getValue();
            }
            if (execute.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                //success
                apiResonse = ApiResonse.generateStatus("100", "success", responseType, resonse);
            } else {
                apiResonse = ApiResonse.generateStatus("101", "error , status  :" + execute.getStatusLine().getStatusCode() + " ,  status text : " + execute.getStatusLine().getReasonPhrase(), responseType, resonse);
            }
        } catch (Exception ex) {
            logger.error(ex, ex);
            apiResonse = ApiResonse.generateError();
        }
        return apiResonse;
    }

}
