import { AdminMainPage } from './AdminMainPage';
import { MedicalMainPage } from './MedicalMainPage';
import { PatientMainPage } from './PatientMainPage';
import { ProfileManagementPage } from './ProfileManagementPage';
import { User } from '../viewmodel/UserModel';

@Entry
@Component
struct MainPage {
  @State private currentIndex: number = 0;
  private currentUser: User | undefined = AppStorage.get<User>('currentUser');

  @Builder
  MainContent() {
    if (this.currentUser && this.currentUser.role) {
      if(this.currentUser.role === 'admin') AdminMainPage()
      else if(this.currentUser.role === 'doctor' || this.currentUser.role === 'expert') MedicalMainPage()
      else if(this.currentUser.role === 'patient') PatientMainPage()
      else {
        Text('未知角色, 无法加载主页')
          .fontSize(20)
          .fontColor(Color.Red)
      }
    } else {
      Text('用户信息丢失, 无法加载主页')
        .fontSize(20)
        .fontColor(Color.Red)
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: new TabsController() }) {
      TabContent() {
        this.MainContent()
      }
      .tabBar(this.TabBuilder("首页", 0))

      TabContent() {
        ProfileManagementPage()
      }
      .tabBar(this.TabBuilder("我的", 1))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .backgroundColor($r('app.color.background_background'))
    .width('100%')
    .height('100%')
  }

  @Builder TabBuilder(title: string, index: number) {
    Column() {
      // 可以在这里添加图标
      // Image(this.currentIndex === index ? 'selected_icon.png' : 'unselected_icon.png')
      //   .width(24).height(24)
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