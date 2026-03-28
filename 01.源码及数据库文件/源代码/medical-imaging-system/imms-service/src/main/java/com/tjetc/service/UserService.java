package com.tjetc.service;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.User;

public interface UserService {
    //注册
    JsonResult register(User user);
    //登陆
    JsonResult loginByIdCard(String idCard, String password, String captcha, String sessionCaptcha);
    //当前用户

    JsonResult current();

    JsonResult getUserById(Long id);

    JsonResult updateUser(User user);

    JsonResult searchUsers(String username);

    JsonResult adminPage(int pageNo, int pageSize, User user);

    JsonResult deleteUserById(Long id);

    JsonResult checkUsernameExist(String username);

    JsonResult loginByPhone(String phone, String password, String captcha, String sessionCaptcha);
}