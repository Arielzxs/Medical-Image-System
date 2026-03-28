package com.tjetc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tjetc.entity.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface UserMapper extends BaseMapper<User> {
    User selectByIdCard(String idCard);

    /**
     * 身份证密码登陆
     * @param idCard
     * @param password
     * @return
     */
    User selectByIdCardAndPassword(@Param("idCard") String idCard, @Param("password") String password);

    /**
     * 手机号密码登陆
     * @param phone
     * @param password
     * @return
     */
    User selectByPhoneAndPassword(@Param("phone") String phone, @Param("password") String password);

    List<User> searchByUsername(@Param("username") String username);

    User selectByIdCardAndUsername(@Param("idCard") String idCard, @Param("username") String username);
}
