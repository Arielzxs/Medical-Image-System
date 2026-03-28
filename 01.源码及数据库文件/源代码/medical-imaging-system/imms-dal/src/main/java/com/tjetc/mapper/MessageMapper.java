package com.tjetc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tjetc.entity.Message;
import com.tjetc.entity.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface MessageMapper extends BaseMapper<Message> {
    List<User> findConversations(@Param("userId") Long userId);

    /**
     * 删除两个用户之间的所有消息
     * @param userId1
     * @param userId2
     */
    void deleteConversation(@Param("userId1") Long userId1, @Param("userId2") Long userId2);


}