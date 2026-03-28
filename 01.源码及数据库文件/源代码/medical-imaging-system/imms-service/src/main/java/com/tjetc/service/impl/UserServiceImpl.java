package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tjetc.common.api.JsonResult;
import com.tjetc.common.security.JwtTokenUtil;
import com.tjetc.entity.User;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.UserService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class UserServiceImpl implements UserService {
    @Value("${jwt.token.expired}")
    private Integer tokenExpired;

    @Autowired
    private UserMapper userMapper;
    @Override
    //事物回滚
    @Transactional
    public JsonResult register(User user) {
        try{
            log.info(user.toString());
            JsonResult jsonResult = checkUser(user);
            if(jsonResult.getState() != 0){
                return jsonResult;
            }

            LocalDateTime now = LocalDateTime.now();
            user.setCreatedAt(now);
            user.setUpdatedAt(now);
            userMapper.insert(user);
            return JsonResult.success("新增用户成功");
        }
        catch (Exception e) {
            //log.error(e.toString());
            throw new RuntimeException(e);
            // return JsonResult.fail("出错了请联系管理员");
        }
    }

    @Override
    public JsonResult loginByIdCard(String idCard, String password, String captcha, String sessionCaptcha) {
        if (StringUtils.isNotBlank(captcha)) {
            if (!captcha.equalsIgnoreCase(sessionCaptcha)) {
                return JsonResult.fail("验证码错误");
            }
        }

        if (StringUtils.isAnyBlank(idCard, password)) {
            return JsonResult.fail("身份证或密码不能为空");
        }
        User user = userMapper.selectByIdCardAndPassword(idCard, password);
        if (user == null) {
            return JsonResult.fail("身份证或密码错误");
        }
        return generateTokenForUser(user);
    }
    @Override
    public JsonResult loginByPhone(String phone, String password, String captcha, String sessionCaptcha) {
        if (StringUtils.isNotBlank(captcha)) {
            if (!captcha.equalsIgnoreCase(sessionCaptcha)) {
                return JsonResult.fail("验证码错误");
            }
        }

        if (StringUtils.isAnyBlank(phone, password)) {
            return JsonResult.fail("手机号或密码不能为空");
        }
        User user = userMapper.selectByPhoneAndPassword(phone, password);
        if (user == null) {
            return JsonResult.fail("手机号或密码错误");
        }
        return generateTokenForUser(user);
    }
    @Override
    public JsonResult current() {return null;}

    private JsonResult checkUser(User user) {
        String username = user.getUsername();
        String password = user.getPassword();
        String role  = user.getRole();
        if(StringUtils.isAnyBlank(username) || StringUtils.isAnyBlank(password)){
            return JsonResult.fail("用户名或密码不能为空");
        }
        String idCard = user.getIdCard();
        if (StringUtils.isAnyBlank(idCard)) {
            return JsonResult.fail("身份证不能为空");
        }
        if(StringUtils.isAnyBlank(role)){
            return JsonResult.fail("请填写您的职业");
        }
        if(StringUtils.length(username) < 3 || StringUtils.length(username) > 10){
            return JsonResult.fail("用户名的长度是3-10个字符");
        }
        if(StringUtils.length(password) < 8 || StringUtils.length(password) > 20){
            return JsonResult.fail("密码的长度是8-20个字符");
        }
        if(StringUtils.length(idCard) != 18) {
            return JsonResult.fail("身份证不正确");
        }
        User existUser = userMapper.selectByIdCard(idCard);
        log.debug("existUser:{}",existUser);
        if(existUser != null){
            return JsonResult.fail("用户名已经存在");
        }
        return JsonResult.success("");
    }

    @Override
    public JsonResult getUserById(Long id) {
        User user = userMapper.selectById(id);
        if (user != null) {
            user.setPassword(null); // 不返回密码
            return JsonResult.success(user);
        }
        return JsonResult.fail("用户不存在");
    }

    @Override
    public JsonResult updateUser(User user) {
        user.setUpdatedAt(LocalDateTime.now());
        int result = userMapper.updateById(user);
        if (result > 0) {
            return JsonResult.success("用户信息更新成功");
        }
        return JsonResult.fail("用户信息更新失败");
    }

    @Override
    public JsonResult searchUsers(String username) {
        List<User> users = userMapper.searchByUsername(username);
        //将所有用户的密码设置为空
        users.forEach(user -> user.setPassword(null));
        return JsonResult.success(users);
    }

    @Override
    public JsonResult adminPage(int pageNo, int pageSize, User user) {
        Page<User> page = new Page<>(pageNo, pageSize);
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(user.getUsername())) {
            queryWrapper.like("username", user.getUsername());
        }
        if (StringUtils.isNotBlank(user.getPhone())) {
            queryWrapper.like("phone", user.getPhone());
        }
        if (StringUtils.isNotBlank(user.getIdCard())) {
            queryWrapper.like("id_card", user.getIdCard());
        }
        if (StringUtils.isNotBlank(user.getRole())) {
            queryWrapper.eq("role", user.getRole());
        }

        queryWrapper.orderByDesc("created_at");

        userMapper.selectPage(page, queryWrapper);
        return JsonResult.success(page);
    }

    @Override
    public JsonResult deleteUserById(Long id) {
        int result = userMapper.deleteById(id);
        if (result > 0) {
            return JsonResult.success("删除用户成功");
        }
        return JsonResult.fail("删除用户失败");
    }

    @Override
    public JsonResult checkUsernameExist(String username) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", username);
        boolean exists = userMapper.selectCount(queryWrapper) > 0;
        return JsonResult.success(exists);
    }


    private JsonResult generateTokenForUser(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", user.getId());
        claims.put("username", user.getUsername());
        claims.put("role", user.getRole());//根据身份设置用户权限
        String token = JwtTokenUtil.generateToken(claims, "user", tokenExpired);
        user.setPassword(null); // 不返回密码
        return JsonResult.success(token, user);
    }
}