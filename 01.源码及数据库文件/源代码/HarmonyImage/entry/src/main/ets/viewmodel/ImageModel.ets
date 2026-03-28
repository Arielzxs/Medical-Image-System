export interface Image {
  id: number;
  patientId: number;
  modality: string;
  filePath: string;
  tags: string;
  uploadedBy: number;
  uploadedAt: string; // 后端传来的LocalDateTime会序列化为字符串
  patientName?: string; //  ImageMapper.xml 中额外查询的字段
  uploadedName?: string; // ImageMapper.xml 中额外查询的字段
}