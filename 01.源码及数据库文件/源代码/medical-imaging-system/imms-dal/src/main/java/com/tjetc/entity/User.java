package com.tjetc.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    //id
    private Long id;
    //用户名
    private String username;
    //身份证
    private String idCard;
    //年龄
    private Integer age;
    //性别 0表示男，1表示女
    private Integer gender;
    //电话
    private String phone;
    //生日
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;
    //地址
    private String address;
    //密码
    private String password;
    //身份
    private String role;
    //创建时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    //更新时间
    private LocalDateTime updatedAt;
}