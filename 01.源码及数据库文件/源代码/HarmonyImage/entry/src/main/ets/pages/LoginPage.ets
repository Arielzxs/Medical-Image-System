import UserApi from '../apis/UserApi'
import { LoginByIdCardParam, LoginByPhoneParam } from '../params/request/UserRequestParam'
import { User } from '../viewmodel/UserModel'
import { JsonResult } from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @State password: string = ''
  @State loginMethod: 'idCard' | 'phone' = 'idCard';
  @State loginIdentifier: string = '';

  /**
   * 处理登录逻辑
   */
  async handleLogin() {
    if (!this.loginIdentifier) {
      promptAction.showToast({ message: '请输入登录凭证' });
      return;
    }
    if (!this.password) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }
    try {
      let result: JsonResult<User>;

      if (this.loginMethod === 'idCard') {
        const params: LoginByIdCardParam = {
          idCard: this.loginIdentifier,
          password: this.password,
        };
        result = await UserApi.loginByIdCard(params);
      } else {
        const params: LoginByPhoneParam = {
          phone: this.loginIdentifier,
          password: this.password,
        };
        result = await UserApi.loginByPhone(params);
      }
      promptAction.showToast({ message: '登录成功' });

      // 将token与用户信息进行全局存储
      AppStorage.SetOrCreate('token', result.message);
      AppStorage.SetOrCreate('currentUser', result.data);

      // 登陆成功后根据身份跳转不同的页面
      // const role = result.data.role;
      // let targetUrl = 'pages/PatientMainPage'; // 默认
      // if (role === 'admin') {
      //   targetUrl = 'pages/AdminMainPage';
      // } else if (role === 'doctor' || role === 'expert') {
      //   targetUrl = 'pages/MedicalMainPage';
      // }
      router.replaceUrl({ url: 'pages/MainPage' });

    } catch (error) {
      console.error('登录失败:', JSON.stringify(error));
    }
  }

  build() {
    Column() {
      Text("医疗影像云平台")
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 40 })

      Column({ space: 15 }) {
        TextInput({
          placeholder: this.loginMethod === 'idCard' ? '请输入身份证号' : '请输入手机号'
        })
          .type(this.loginMethod === 'phone' ? InputType.PhoneNumber : InputType.Normal)
          .onChange((value: string) => {
            this.loginIdentifier = value;
          })

        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })

        Row({ space: 10 }) {
          ForEach(['idCard', 'phone'], (method: string) => {
            Row() {
              Radio({ value: method, group: 'loginMethod' })
                .checked(this.loginMethod === method)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.loginMethod = method as 'idCard' | 'phone';
                    this.loginIdentifier = '';
                  }
                })
              Text(method === 'idCard' ? '身份证' : '手机号')
            }
          })
        }.margin({ top: 10, bottom: 10 })

        Button('登 录', { type: ButtonType.Capsule, stateEffect: true })
          .width('100%')
          .height(45)
          .fontSize(18)
          .margin({ top: 20 })
          .onClick(() => this.handleLogin())

        // 跳转到注册页面的链接
        Row() {
          Text('还没有账户？')
            .fontColor(Color.Gray)
          Text(' 立即注册')
            .fontColor('#0D9FFB')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.pushUrl({ url: 'pages/RegisterPage' });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 20 })

      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .backgroundColor($r('app.color.background_background'))
  }
}
