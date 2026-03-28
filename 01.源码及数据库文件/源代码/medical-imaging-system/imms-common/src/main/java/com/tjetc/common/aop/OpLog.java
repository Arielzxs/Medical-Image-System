//操作日志
//写入operation_log表中
//自定义注解
package com.tjetc.common.aop;

import java.lang.annotation.*;
//指定该注解用在方法上
@Target(ElementType.METHOD)
//标明注解在程序运行时仍然保留，可以获取信息
// 若使用RetentionPolicy.CLASS 注解只会在编译阶段，运行时就消失
@Retention(RetentionPolicy.RUNTIME)
public @interface OpLog {
    //用来描述用户信息
    String value();
}
