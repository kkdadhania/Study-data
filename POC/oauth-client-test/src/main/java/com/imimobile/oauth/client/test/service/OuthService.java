/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.imimobile.oauth.client.test.service;

import com.imimobile.oauth.client.test.bean.ApiResonse;

/**
 *
 * @author sadashiv.k
 */
public interface OuthService {

    public ApiResonse getAccessTokenByCode(String request);

    public ApiResonse getRecourceData(String body);

    public ApiResonse refreshToken(String body);
}
