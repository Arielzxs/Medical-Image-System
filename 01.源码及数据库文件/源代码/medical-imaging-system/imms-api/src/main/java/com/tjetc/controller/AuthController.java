package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.User;
import com.tjetc.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


//认证、用户管理
@RequestMapping("auth")
@RestController
public class AuthController {
    @Autowired
    private UserService userService;

    /**
     * 用户注册
     * @param user 用户信息
     * @return
     */
    @RequestMapping("register")
    public JsonResult register(@RequestBody  User user) {
        return userService.register(user);
    }

    /**
     * 使用身份证登陆
     * @param idCard 身份证
     * @param password 密码
     * @param captcha 验证吗
     * @param request 请求
     * @return
     */
    @RequestMapping("login_id_card")
    public JsonResult loginByIdCard(@RequestParam("idCard") String idCard, @RequestParam("password") String password, @RequestParam(value = "captcha", required = false) String captcha, HttpServletRequest request) {
        String sessionCaptcha = (String) request.getSession().getAttribute("vrifyCode");
        return userService.loginByIdCard(idCard, password, captcha, sessionCaptcha);
    }

    /**
     * 根据手机号登陆
     * @param phone 手机号
     * @param password 密码
     * @param captcha 验证吗
     * @param request 请求
     * @return
     */
    @RequestMapping("login_phone")
    public JsonResult loginByPhone(@RequestParam("phone") String phone, @RequestParam("password") String password, @RequestParam(value = "captcha", required = false) String captcha, HttpServletRequest request) {
        String sessionCaptcha = (String) request.getSession().getAttribute("vrifyCode");
        return userService.loginByPhone(phone, password, captcha, sessionCaptcha);
    }
}