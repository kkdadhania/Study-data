/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.imimobile.oauth.client.test;

import com.imimobile.oauth.client.test.bean.ApiResonse;
import com.imimobile.oauth.client.test.service.OuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.util.MimeTypeUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author sadashiv.k
 */
@Controller
public class IndexController {

    @Autowired
    @Qualifier("outhServiceImpl")
    private OuthService service;

    @RequestMapping("")
    public String homePage() {
        return "forward:index";
    }

    @RequestMapping("index")
    public String index() {
        return "index";
    }

    @RequestMapping("callback")
    public @ResponseBody
    String callback() {
        return "";
    }

    @RequestMapping(value = "access_token", method = RequestMethod.POST, produces = MimeTypeUtils.APPLICATION_JSON_VALUE)
    public @ResponseBody
    ApiResonse accessToken(@RequestBody String body) {
        System.out.println("body" + body);
        return service.getAccessTokenByCode(body);
    }
    @RequestMapping(value = "resource", method = RequestMethod.POST, produces = MimeTypeUtils.APPLICATION_JSON_VALUE)
    public @ResponseBody
    ApiResonse resource(@RequestBody String body) {
        System.out.println("body" + body);
        return service.getRecourceData(body);
    }
    @RequestMapping(value = "refresh", method = RequestMethod.POST, produces = MimeTypeUtils.APPLICATION_JSON_VALUE)
    public @ResponseBody
    ApiResonse refresh(@RequestBody String body) {
        System.out.println("body" + body);
        return service.refreshToken(body);
    }

}
