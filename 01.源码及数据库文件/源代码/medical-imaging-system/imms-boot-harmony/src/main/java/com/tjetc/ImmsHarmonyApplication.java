package com.tjetc;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@MapperScan(basePackages = "com.tjetc.mapper")
@EnableScheduling // 开启定时任务
public class ImmsHarmonyApplication {
    public static void main(String[] args) {
        SpringApplication.run(ImmsHarmonyApplication.class, args);
    }
}