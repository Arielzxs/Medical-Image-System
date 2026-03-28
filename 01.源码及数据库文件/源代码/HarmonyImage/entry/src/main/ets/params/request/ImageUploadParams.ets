/**
 * 定义上传图片时需要的所有参数
 */
export interface ImageUploadParams {
  uri: string; // 图片的内部URI
  patientName: string;
  patientIdCard: string;
  modality: string;
  tags?: string; // tags是可选的
  uploadedBy: number; // 上传者ID
}