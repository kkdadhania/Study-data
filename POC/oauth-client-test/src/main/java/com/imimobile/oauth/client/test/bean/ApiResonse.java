/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.imimobile.oauth.client.test.bean;

/**
 *
 * @author sadashiv.k
 */
public class ApiResonse {

    private String code;
    private String status;
    private String responseType;
    private String response;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResponseType() {
        return responseType;
    }

    public void setResponseType(String responseType) {
        this.responseType = responseType;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public static ApiResonse generateError() {
        ApiResonse apiResonse = new ApiResonse();
        apiResonse.setCode("101");
        apiResonse.setStatus("error");
        return apiResonse;
    }

    public static ApiResonse generateError(String status) {
        ApiResonse apiResonse = new ApiResonse();
        apiResonse.setCode("101");
        apiResonse.setStatus(status);
        return apiResonse;
    }

    public static ApiResonse generateStatus(String code, String status, String responseType, String response) {
        ApiResonse apiResonse = new ApiResonse();
        apiResonse.setCode(code);
        apiResonse.setStatus(status);
        apiResonse.setResponseType(responseType);
        apiResonse.setResponse(response);
        return apiResonse;
    }

}
