package com.tjetc.controller;

import com.tjetc.common.aop.OpLog;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.User;
import com.tjetc.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    /**
     * 根据用户id获取用户
     * @param id
     * @return
     */
    @RequestMapping("/{id}")
    public JsonResult getUserById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    /**
     * 更新用户信息
     * @param user 新的用户信息
     * @return
     */
    @OpLog("更新了用户信息")
    @PostMapping ("/update")
    public JsonResult updateUser(@RequestBody User user) {
        return userService.updateUser(user);
    }

    /**
     * 根据用户名查询用户
     * @param username 用户名
     * @return
     */
    @RequestMapping ("/search")
    public JsonResult searchUsers(@RequestParam String username) {
        return userService.searchUsers(username);
    }
}
