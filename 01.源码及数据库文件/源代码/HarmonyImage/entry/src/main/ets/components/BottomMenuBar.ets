import router from '@ohos.router';
import { User } from '../viewmodel/UserModel';

@Component
export struct BottomMenuBar {
  @State currentIndex: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent()
        .tabBar(this.TabBuilder("功能", 0))
      TabContent()
        .tabBar(this.TabBuilder("我的", 1))
    }
    .height(60)
    .backgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentIndex = index;
      if (index === 0) {
        // 根据用户角色动态跳转到对应的主页
        const userInfo: User | undefined = AppStorage.get<User>('currentUser');
        if (userInfo && userInfo.role) {
          switch (userInfo.role) {
            case 'admin':
              router.pushUrl({ url: 'pages/AdminMainPage' });
              break;
            case 'doctor'||'expert':
              router.pushUrl({ url: 'pages/MedicalMainPage' });
              break;
            case 'patient':
              router.pushUrl({ url: 'pages/PatientMainPage' });
              break;
            default:
            // 默认跳转或错误处理
              router.pushUrl({ url: 'pages/IndexPage' });
              break;
          }
        }
      } else if (index === 1) {
        router.pushUrl({ url: 'pages/ProfileManagementPage' });
      }
    })
  }

  @Builder TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === index ? '#1698CE' : '#666666')
        .fontSize(12)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}