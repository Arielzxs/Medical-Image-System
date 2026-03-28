import { AxiosHeaders, InternalAxiosRequestConfig, FormData } from '@ohos/axios';
import { httpRequest, JsonResult} from '../utils/HttpUtil';
import { ImageUploadParams } from '../params/request/ImageUploadParams';

import {Image} from '../viewmodel/ImageModel'
import {ImageSearchParams} from  '../params/request/ImageSearchParams'
export interface FileUploadParams extends ImageUploadParams {
  fileData: ArrayBuffer;
  fileName: string;
}


export async function uploadImage(params: FileUploadParams): Promise<boolean> {
  const url = '/image/upload';

  const formData = new FormData();

  formData.append('image',params.uri)
  formData.append('patientName', params.patientName);
  formData.append('patientIdCard', params.patientIdCard);
  formData.append('modality', params.modality);
  formData.append('tags', params.tags || '');
  formData.append('uploadedBy', params.uploadedBy.toString());

  const config: InternalAxiosRequestConfig = {
    headers: new AxiosHeaders().set("Content-Type", 'multipart/form-data')
  };
  try {
    console.log(JSON.stringify(formData.get('uploadedBy')))
    await httpRequest.post<JsonResult<object>, FormData>(url, formData, config);
    return true;
  } catch (error) {
    console.error(`Upload image failed: ${JSON.stringify(error)}`);
    return false;
  }
}

export async function searchImages(params: ImageSearchParams):Promise<Image[]> {
  //处理get请求的url地址
  const url = '/search/images';

  const cleanParams: ImageSearchParams = {};
  if (params.patientName) cleanParams.patientName = params.patientName;
  if (params.patientIdCard) cleanParams.patientIdCard = params.patientIdCard;
  if (params.modality) cleanParams.modality = params.modality;
  if (params.tags) cleanParams.tags = params.tags;
  if (params.startDate) cleanParams.startDate = params.startDate.substring(0, 19);
  if (params.endDate) cleanParams.endDate = params.endDate.substring(0, 19);
  // console.log(cleanParams.startDate)
  // console.log(cleanParams.endDate)
  try {
    const response = await httpRequest.get<JsonResult<Image[]>, ImageSearchParams>(url, cleanParams);
    if (response && response.state === 0) {
      return response.data || [];
    } else {
      console.error('Failed to search images:', response?.message || 'Unknown error');
      return [];
    }
  } catch (error) {
    console.error('Error during image search:', JSON.stringify(error));
    return [];
  }
}
