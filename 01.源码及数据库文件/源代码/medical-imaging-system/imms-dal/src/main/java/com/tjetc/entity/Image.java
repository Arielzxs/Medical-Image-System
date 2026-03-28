package com.tjetc.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName("image")
public class Image {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long patientId;
    private String modality;
    private String filePath;
    private String tags;
    private Long uploadedBy;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime uploadedAt;

    // 用于接收关联查询出的用户名
    @TableField(exist = false)
    private String patientName;

    @TableField(exist = false)
    private String uploadedName;
}