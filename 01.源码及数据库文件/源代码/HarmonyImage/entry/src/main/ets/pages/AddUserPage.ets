import UserApi from '../apis/UserApi';
import { User } from '../viewmodel/UserModel';
import promptAction from '@ohos.promptAction';
import AdminApi from '../apis/AdminApi'

interface DatePickerValue {
  year: number;
  month: number;
  day: number;
}

@Entry
@Component
struct ProfileManagementPage {
  @State UserInformation: User = {
    username: '',
    password:'',
    role:'patient',
    idCard: '',
    phone: '',
    address: '',
    age: 0,
    gender: 0,
    birthDate: ''
  };

  @State private isAdding: boolean = false;

  aboutToAppear() {
    const userInfo: User | undefined = AppStorage.get<User>('currentUser');
    if (userInfo && userInfo.id) {
      // this.loadUserData(userInfo.id);
    } else {
      promptAction.showToast({ message: '用户未登录' });
    }
  }


  async submitAdd() {
    this.isAdding = true
    try {
      // console.log(JSON.stringify(this.UserInformation))
      const response = await AdminApi.addUser(this.UserInformation)
      if(response.state == 0) {
        promptAction.showToast({message:'新增用户成功'})
      }
      else {
        this.isAdding = false
        promptAction.showToast({message:`新增用户失败：${response.message}`})
      }
    }
    catch (error){
      promptAction.showToast({ message: '网络请求失败' });
    }

  }

  build() {
    Column() {
      Text('新增用户')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .width('90%')
        .textAlign(TextAlign.Start)

      Scroll() {
        Column({ space: 5 }) {
          // 用户名
          Row() {
            Text('用户名')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.username })
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.username = val)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))
          //密码
          Row() {
            Text('密码')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.password })
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.password = val)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 身份证号
          Row() {
            Text('身份证号')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.idCard })
              .fontColor(Color.Gray)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.idCard = val)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))
          Row() {
            Text('身份')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            Row({ space: 10 }) {
              Radio({ value: '0', group: 'role' })
                .checked(this.UserInformation.role === 'patient')
                .onChange((isChecked: boolean) => {
                  if (isChecked) this.UserInformation.role = 'patient'
                })
              Text("患者")
              Radio({ value: '1', group: 'role' })
                .checked(this.UserInformation.role === 'doctor')
                .onChange((isChecked: boolean) => {
                  if (isChecked) this.UserInformation.role = 'doctor'
                })
              Text("医生")

              Radio({ value: '2', group: 'role' })
                .checked(this.UserInformation.role === 'admin')
                .onChange((isChecked: boolean) => {
                  if (isChecked) this.UserInformation.role = 'admin'
                })
              Text("管理员")
            }
            .justifyContent(FlexAlign.Start)
            .flexGrow(1)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))
          // 电话
          Row() {
            Text('电话')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.phone })
              .type(InputType.PhoneNumber)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.phone = val)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 年龄
          Row() {
            Text('年龄')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.age ? this.UserInformation.age.toString() : '0' })
              .type(InputType.Number)
              // .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.age = parseInt(val) || 0)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 性别
          Row() {
            Text('性别')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            Row({ space: 20 }) {
              Radio({ value: '0', group: 'gender' })
                .checked(this.UserInformation.gender === 0)
                .onChange((isChecked: boolean) => {
                  if (isChecked) this.UserInformation.gender = 0
                })
              Text("男")
              Radio({ value: '1', group: 'gender' })
                .checked(this.UserInformation.gender === 1)
                .onChange((isChecked: boolean) => {
                  if (isChecked) this.UserInformation.gender = 1
                })
              Text("女")
            }
            .justifyContent(FlexAlign.Start)
            .flexGrow(1)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 出生日期
          Row() {
            Text('出生日期')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            DatePicker({
              start: new Date('1920-01-01'),
              end: new Date(),
              selected: this.UserInformation.birthDate ? new Date(this.UserInformation.birthDate) : new Date()
            })
              // .enabled(this.isEditing)
              .backgroundColor(Color.Transparent)
              .onChange((value: DatePickerValue) => {
                this.UserInformation.birthDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
              })
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 地址
          Row() {
            Text('地址')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ text: this.UserInformation.address })
              // .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.UserInformation.address = val)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 10, right: 10 })

        }.width('100%')
        .backgroundColor(Color.White)
        .borderRadius(15)
        .padding({ top: 10, bottom: 10 })

      }.layoutWeight(1)

      Row({ space: 20 }) {
          Button('提交新增')
            .type(ButtonType.Capsule)
            .width('50%')
            .height(45)
            .fontSize(18)
            .onClick(() => this.submitAdd())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_background'))
    .justifyContent(FlexAlign.Start)
  }
}

