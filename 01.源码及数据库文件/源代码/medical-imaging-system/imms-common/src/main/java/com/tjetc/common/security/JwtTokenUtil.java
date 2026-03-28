package com.tjetc.common.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys; // 导入 Keys 类
import lombok.extern.slf4j.Slf4j;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

/**
 * jwt token 生成工具类
 */
@Slf4j
public class JwtTokenUtil {
    //jwt加密的密钥（字符串），为了安全，长度至少要32个字符
    private final static String SECRET_KEY_STRING = "abc1234567890abc1234567890abc1234567890";

    // 从一个固定的字符串生成一个确定的、每次都相同的密钥
    private static final SecretKey key = Keys.hmacShaKeyFor(SECRET_KEY_STRING.getBytes(StandardCharsets.UTF_8));

    /**
     * 生成jwt token
     *
     * @param claims
     * @param subject
     * @param expiration
     * @return
     */
    public static String generateToken(Map<String, Object> claims, String subject, int expiration) {
        final Date now = new Date();
        final Date expirationDate = calculateExpirationDate(now, expiration);
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(now)
                .expiration(expirationDate)
                .signWith(key)
                .compact();
    }

    private static Date calculateExpirationDate(Date createdDate, int expiration) {
        return new Date(createdDate.getTime() + expiration);
    }

    /**
     * 解密Jwt内容
     *
     * @param token
     * @return Claims
     */
    public static Claims parseJwt(String token) {
        // 直接返回解析结果，无需额外变量
        return Jwts.parser()
                .verifyWith(key) // 设置用于验证的密钥
                .build()
                .parseSignedClaims(token) // 解析token
                .getPayload(); // 获取负载内容
    }
}