import {User} from '../../viewmodel/UserModel'

/**
 * 身份证登陆请求参数
 */
export interface LoginByIdCardParam{
  idCard:string;
  password:string;
}

/**
 * 手机号登陆请求参数
 */
export interface LoginByPhoneParam{
  phone: string;
  password: string;
}

export interface RegisterParam {
  username: string;
  idCard: string;
  age: number;
  gender: number;
  phone: string;
  birthDate: string;
  address: string;
  password: string;
  role: 'admin' | 'doctor' | 'expert' | 'patient';
}

// export interface DatePickerValue {
//   year: number;
//   month: number;
//   day: number;
// }

