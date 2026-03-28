package com.tjetc.controller;

import com.tjetc.common.aop.OpLog;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.User;
import com.tjetc.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员管理用户
 */
@RestController
@RequestMapping("/admin")
public class AdminController {
    @Autowired
    private UserService userService;

    /**
     * 分页查询用户信息
     * @param pageNo 页码
     * @param pageSize 每页显示数量
     * @param username 用户名
     * @param phone 电话
     * @param idCard 身份证
     * @param role 身份
     * @return
     */
    @RequestMapping("/page")
    public JsonResult page(
            @RequestParam(defaultValue = "1") int pageNo,
            @RequestParam(defaultValue = "5") int pageSize,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) String idCard,
            @RequestParam(required = false) String role) {
        User user = new User();
        user.setUsername(username);
        user.setPhone(phone);
        user.setIdCard(idCard);
        user.setRole(role);
        return userService.adminPage(pageNo, pageSize, user);
    }

    /**
     * 根据用户id删除用户
     * @param id 用户id
     * @return
     */
    @OpLog("删除了一个用户")
    //根据用户id删除用户
    @RequestMapping("/delete/{id}")
    public JsonResult adminDeleteById(@PathVariable Long id) {
        return userService.deleteUserById(id);
    }

    /**
     * 添加一个用户
     * @param user
     * @return
     */
    @OpLog("添加了一个用户")
    @RequestMapping("/add")
    public JsonResult adminAdd(@RequestBody User user) {
        return userService.register(user);
    }

    /**
     * 根据用户名检查用户是否存在
     * @param username 用户名
     * @return
     */
    @RequestMapping("/check-exist")
    public JsonResult adminCheckExist(@RequestParam String username) {
        return userService.checkUsernameExist(username);
    }

    /**
     * 根据id获取用户的详情信息
     * @param id 用户 id
     * @return
     */
    @RequestMapping("/detail/{id}")
    public JsonResult adminDetail(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    /**
     * 更新用户信息
     * @param user 新的用户信息
     * @return
     */
    @OpLog("更新了一个用户信息")
    @RequestMapping("/update")
    public JsonResult adminUpdate(@RequestBody User user) {
        return userService.updateUser(user);
    }
}