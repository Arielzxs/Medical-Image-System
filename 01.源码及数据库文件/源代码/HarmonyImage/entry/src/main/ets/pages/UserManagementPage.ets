import { User } from '../viewmodel/UserModel'
import AdminApi from '../apis/AdminApi'
import { GetPageRequestConfig } from '../viewmodel/PageModel'
import promptAction from '@ohos.promptAction';
import { JSON } from '@kit.ArkTS';
import router from '@ohos.router'
@Entry
@Component
struct UserManagementPage {

  @State users: User[] = []
  @State total: number = 0
  @State isLoading: boolean = false;
  @State searchMessage: string = '请输入条件进行搜索';

  @State
  SearchRequestData: GetPageRequestConfig = {
    pageNo: 1,
    pageSize: 10,
    phone: '',
    username: '',
    idCard: '',
    role: ''
  }

  aboutToAppear() {
    this.performSearch(true);
  }

  async performSearch(isRefresh: boolean = false) {
    if (isRefresh) {
      this.SearchRequestData.pageNo = 1;
    }
    this.isLoading = true;
    if (isRefresh) {
      this.searchMessage = '';
    }

    try {
      const result = await AdminApi.getPage(this.SearchRequestData);

      if (result && result.state == 0 && result.data && Array.isArray(result.data.records)) {
        const newUsers = result.data.records;
        this.total = result.data.total ?? 0;

        if (isRefresh) {
          this.users = newUsers;
        } else {
          this.users.push(...newUsers);
        }

        if (this.users.length === 0) {
          this.searchMessage = '未找到符合条件的用户';
        }
      } else {
        if (isRefresh) {
          this.users = [];
        }
        this.searchMessage = result?.message || '加载失败，请稍后重试';
        promptAction.showToast({ message: this.searchMessage });
      }
    } catch (e) {
      this.searchMessage = "网络请求异常";
      promptAction.showToast({ message: this.searchMessage });
    } finally {
      this.isLoading = false;
    }
  }
  // 删除用户确认对话框
  async confirmDeleteUser(userId: number) {
    try {
      const userInfo: User | undefined = AppStorage.get<User>('currentUser');
      if(userInfo?.id === userId) {
        promptAction.showToast({ message: '异常操作，不能删除自己' });
        return
      }
      const result = await promptAction.showDialog({
        title: '确认删除',
        message: '您确定要删除该用户吗？此操作无法撤销。',
        buttons: [
          {
            text: '取消',
            color: '#000000'
          },
          {
            text: '确定',
            color: '#FF0000'
          }
        ]
      });

      if (result.index === 1) {
        try {
          const deleteResult = await AdminApi.deleteUser(userId);
          if (deleteResult && deleteResult.state === 0) {
            promptAction.showToast({ message: '删除成功' });
            this.performSearch(true);
          } else {
            promptAction.showToast({ message: deleteResult?.message || '删除失败' });
          }
        } catch (error) {
          promptAction.showToast({ message: '网络请求异常' });
        }
      }
    } catch (error) {
      console.error('Dialog error: ' + JSON.stringify(error));
    }
  }
  async addUser(){
    router.pushUrl({ url: 'pages/AddUserPage' });
  }
  //跳转到修改用户页面
  editUser(userId: number) {
    router.pushUrl({ url: 'pages/EditUserPage', params: { "userId": userId } });
  }

  build() {
    Column() {
      Text('用户管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      Column({ space: 10 }) {
        TextInput({ placeholder: '用户姓名'}).onChange((value) => {
          this.SearchRequestData.username = value
        })
        TextInput({ placeholder: '用户身份证' }).onChange((value) => {
          this.SearchRequestData.idCard = value
        })
        TextInput({ placeholder: '用户手机号' }).onChange((value) => {
          this.SearchRequestData.phone = value;
        })

        Row() {
          Text("身份").width('25%')
          Row({ space: 20 }) {
            Radio({ value: "patient", group: "role" })
              .checked(this.SearchRequestData.role === 'patient')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.SearchRequestData.role = 'patient'
              })
            Text("患者")
            Radio({ value: "doctor", group: "role" })
              .checked(this.SearchRequestData.role === 'doctor')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.SearchRequestData.role = 'doctor'
              })
            Text("医生")
          }
        }.width('100%')

        Row({ space: 10 }) {
          Button('查询')
            .onClick(() => {
              this.performSearch(true);
            })
            .layoutWeight(1)

          Button('新增用户')
            .onClick(() => {
              this.addUser();
            })
            .layoutWeight(1)
            .backgroundColor(Color.Green)
        }
        .width('90%')
        .margin({ top: 10 })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(10)
      .shadow({ radius: 5, color: '#f0f0f0' })
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(
          this.users,
          (item: User) => {
            ListItem() {
              this.UserRow(item)
            }
          },
          (item: User, index: number) => (item.id ?? index).toString()
        )
      }
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
      .layoutWeight(1)
      .width('90%')
      .onScrollIndex((start, end) => {
        if (end === this.users.length - 1 && this.users.length < this.total && !this.isLoading) {
          this.SearchRequestData.pageNo++;
          this.performSearch(false);
        }
      })


      if (this.isLoading && this.users.length === 0) {
        Text('正在加载中...')
          .fontSize(16)
          .margin(20)
      } else if (this.users.length === 0) {
        Text(this.searchMessage)
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder UserRow(user: User) {
    Row() {
      Column({ space: 5 }) {
        Text(`姓名: ${user.username || 'N/A'}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(`角色: ${user.role || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`手机号: ${user.phone || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`身份证: ${user.idCard || 'N/A'}`)
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 操作按钮
      Column({ space: 8 }) {
        Button('修改')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .width(80)
          .height(35)
          .onClick(() => {
            if (user.id) {
              this.editUser(user.id);
            } else {
              promptAction.showToast({ message: '用户ID不存在' });
            }
          })
        Button('删除')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .width(80)
          .height(35)
          .backgroundColor(Color.Red)
          .onClick(() => {
            if (user.id) {
              this.confirmDeleteUser(user.id);
            } else {
              promptAction.showToast({ message: '用户ID不存在' });
            }
          })
      }
      .justifyContent(FlexAlign.Center)
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width('100%')
  }
}