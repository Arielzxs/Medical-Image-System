package com.tjetc.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName("image_share")
public class ImageShare {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long imageId;
    private Long sharedTo;
    private Long sharedBy;
    private LocalDateTime sharedAt;
}
